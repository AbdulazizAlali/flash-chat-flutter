import 'dart:async';
import 'dart:io';
import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_chat/src/pages/chat/chat.dart';
import 'package:flutter_firebase_chat/src/pages/chats/chats.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatService {
  Firestore _firestore = Firestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  AuthService _authService = AuthService();
  StreamSubscription _watchChatsSubscription;

  ChatService() {}

  Future<void> dispose() {
    return _watchChatsSubscription?.cancel();
  }

  Future<List<ChatModel>> getChats() async {
    List<String> chatIds = await _getCurrentUserChatIds();
    if (chatIds.length > 0)
      return _getChatsByIds(chatIds);
    else
      return [];
  }

  Future<ChatsUsersModel> getChatsAndUsersByQuery(String query) async {
    String currentUserId = await _authService.getCurrentUserId();
    List<DocumentSnapshot> usersDocs = await _getUsersDocsByQuery(query);
    List<UserModel> users = [];
    List<ChatModel> chats = [];
    List<String> chatIds = [];
    usersDocs.forEach((usersDoc) {
      if (usersDoc.documentID != currentUserId) {
        users.add(UserModel(
            id: usersDoc.documentID,
            imageUrl: usersDoc.data['imageUrl'],
            name: usersDoc.data['username']));
        chatIds += usersDoc.data['chatIds'].cast<String>();
      }
    });
    chatIds = chatIds.toSet().toList();
    if (chatIds.length > 0) {
      List<String> currentUserChatIds = await _getCurrentUserChatIds();
      if (currentUserChatIds.length > 0) {
        List<String> filteredChatIds = [];
        currentUserChatIds.forEach((currentUserChatId) {
          if (chatIds.contains(currentUserChatId))
            filteredChatIds.add(currentUserChatId);
        });
        if (filteredChatIds.length > 0)
          chats = await _getChatsByIds(filteredChatIds);
      }
    }
    users = users
        .where((user) =>
            chats.indexWhere((chat) =>
                (chat.members.length == 2) &&
                chat.members.containsKey(user.id)) ==
            -1)
        .toList();
    return ChatsUsersModel(chats: chats, users: users);
  }

  Stream<List> getMessages(String chatId, [DocumentSnapshot docSnapshot]) {
    var messagesQuery = _firestore
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(10);
    if (docSnapshot != null)
      messagesQuery = messagesQuery.startAfterDocument(docSnapshot);
    return messagesQuery.snapshots().transform(
        StreamTransformer<QuerySnapshot, List>.fromHandlers(
            handleData: (messagesSnapshot, sink) async {
      String currentUserId = await _authService.getCurrentUserId();
      List<MessageModel> messages = messagesSnapshot.documents
          .map((messageDoc) => MessageModel(
              content: messageDoc.data['content'],
              contentType: messageDoc.data['contentType'],
              date: (messageDoc.data['date']),
              userId: (currentUserId != messageDoc.data['userId'])
                  ? messageDoc.data['userId']
                  : null,
              docSnapshot: messageDoc))
          .toList()
          .reversed
          .toList();
      sink.add(messages);
    }));
  }

  Future<DocumentReference> sendTextMessage(
      String chatId, String message) async {
    return _firestore
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .add({
      'content': message,
      'contentType': 'text',
      'date': DateTime.now(),
      'userId': await _authService.getCurrentUserId()
    });
  }

  Future<DocumentReference> sendImageMessage(
      String chatId, File message) async {
    StorageReference firebaseStorageRef = _firebaseStorage.ref().child(
        'messages/image/' +
            chatId +
            DateTime.now().millisecondsSinceEpoch.toString() +
            '.jpg');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(message);
    String imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return _firestore
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .add({
      'content': imageUrl,
      'contentType': 'image',
      'date': DateTime.now(),
      'userId': await _authService.getCurrentUserId()
    });
  }

  Future<DocumentReference> sendFileMessage(String chatId, File message) async {
    StorageReference firebaseStorageRef = _firebaseStorage.ref().child(
        'messages/file/' +
            chatId +
            DateTime.now().millisecondsSinceEpoch.toString() +
            message.path.substring(message.path.lastIndexOf("/")));
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(message);
    String fileUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return _firestore
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .add({
      'content': fileUrl,
      'contentType': 'file',
      'date': DateTime.now(),
      'userId': await _authService.getCurrentUserId()
    });
  }

  Future<Map> createChat(List<String> userIds) async {
    userIds.add(await _authService.getCurrentUserId());
    String newChatId =
        (await _firestore.collection('chats').add({})).documentID;
    Iterable<Future<Map>> membersFutures = userIds.map((userId) =>
        _updateUserChatIdsAndGetUpdatedMembers(newChatId, userId, {}));
    List<Map> membersList = await Future.wait(membersFutures);
    Map members = {};
    membersList.forEach((memberMap) => members.addAll(memberMap));
    await _firestore
        .collection('chats')
        .document(newChatId)
        .updateData({'members': members});
    return {'chatId': newChatId, 'members': members};
  }

  Future<Map> updateLastVisitTimestamp(String chatId, Map members) async {
    String currentUserId = await _authService.getCurrentUserId();
    members[currentUserId]['lastVisitTimestamp'] = DateTime.now();
    await _updateChatMembers(chatId, members);
    return members;
  }

  Stream<Map> getChatMembersInfo(String chatId) {
    Stream chatStream =
        _firestore.collection('chats').document(chatId).snapshots();
    return chatStream.transform(
        StreamTransformer<DocumentSnapshot, Map>.fromHandlers(
            handleData: (chatSnapshot, sink) async {
      String currentUserId = await _authService.getCurrentUserId();
      Map members = chatSnapshot.data['members'];
      sink.add({
        'members': members,
        'chatName': _getChatNameByMembers(currentUserId, members)
      });
    }));
  }

  Future<List<UserModel>> getUsersByQueryExceptMembers(
      String query, Map members) async {
    List<DocumentSnapshot> usersDocs = await _getUsersDocsByQuery(query);
    usersDocs = usersDocs
        .where((usersDoc) => !members.containsKey(usersDoc.documentID))
        .toList();
    return usersDocs
        .map((usersDoc) => UserModel(
            id: usersDoc.documentID,
            name: usersDoc.data['username'],
            imageUrl: usersDoc.data['imageUrl']))
        .toList();
  }

  Future<void> addChatMember(String chatId, String userId, Map members) async {
    members =
        await _updateUserChatIdsAndGetUpdatedMembers(chatId, userId, members);
    return _firestore
        .collection('chats')
        .document(chatId)
        .updateData({'members': members});
  }

  Future removeChat(String chatId, Map members) async {
    List<String> userIds = members.keys.toList();
    Iterable<Future<void>> userFutures = userIds.map((userId) async {
      DocumentReference userDocRef =
          _firestore.collection('users').document(userId);
      DocumentSnapshot userSnapshot = await userDocRef.get();
      List<String> newChatIds = userSnapshot.data['chatIds'].cast<String>();
      newChatIds.removeWhere((newChatId) => newChatId == chatId);
      return userDocRef.updateData({'chatIds': newChatIds});
    });
    await Future.wait(userFutures);
    DocumentReference chatDocRef =
        _firestore.collection('chats').document(chatId);
    QuerySnapshot chatsSnapshot =
        await chatDocRef.collection('messages').getDocuments();
    Iterable<Future<void>> messageFutures =
        chatsSnapshot.documents.map((chatDoc) => chatDoc.reference.delete());
    await Future.wait(messageFutures);
    return chatDocRef.delete();
  }

  Stream<List<ChatModel>> watchChats() async* {
    DocumentReference userRef = _firestore
        .collection('users')
        .document(await _authService.getCurrentUserId());
    yield* userRef.snapshots().transform(
        StreamTransformer<DocumentSnapshot, List<ChatModel>>.fromHandlers(
            handleData: (userSnapshot, sink) async {
      List<String> chatIds = userSnapshot.data['chatIds'].cast<String>();
      if (chatIds.length > 0) {
        _watchChatsSubscription?.cancel();
        _watchChatsSubscription = _watchChatsByIds(chatIds).listen((chats) {
          sink.add(chats);
        });
      } else
        sink.add([]);
    }));
  }

  Stream<List<ChatModel>> _watchChatsByIds(List<String> chatIds) {
    var chatsQuery = _firestore
        .collection('chats')
        .where(FieldPath.documentId, whereIn: chatIds);
    return chatsQuery.snapshots().transform(
        StreamTransformer<QuerySnapshot, List<ChatModel>>.fromHandlers(
            handleData: (chatsSnapshot, sink) async {
      sink.add(await _getChatsByDocs(chatsSnapshot.documents));
    }));
  }

  Future<List<ChatModel>> _getChatsByDocs(
      List<DocumentSnapshot> chatDocs) async {
    if (chatDocs.length == 0) return [];

    String currentUserId = await _authService.getCurrentUserId();
    return Future.wait(chatDocs.map((chatDoc) async {
      QuerySnapshot messagesSnapshot = await _firestore
          .collection('chats')
          .document(chatDoc.documentID)
          .collection('messages')
          .orderBy('date', descending: true)
          .limit(1)
          .getDocuments();
      List<DocumentSnapshot> messageDocs = messagesSnapshot.documents;

      Map members = chatDoc.data['members'];
      List<String> imageUrls = [];
      if (members != null)
        members.forEach((key, value) {
          if (key != currentUserId) imageUrls.add(value['imageUrl']);
        });
      else
        imageUrls.add('');

      bool hasUnreadMessages;
      if (messageDocs.length > 0 && members != null) {
        String latestMessageUserId = messageDocs[0].data['userId'];
        DateTime latestMessageDate = messageDocs[0].data['date'].toDate();
        hasUnreadMessages = (members[currentUserId] != null) &&
            (!members[currentUserId].containsKey('lastVisitTimestamp') ||
                (members[currentUserId].containsKey('lastVisitTimestamp') &&
                    (latestMessageUserId != currentUserId) &&
                    (latestMessageDate.isAfter(members[currentUserId]
                            ['lastVisitTimestamp']
                        .toDate()))));
      } else
        hasUnreadMessages = true;

      return ChatModel(
          id: chatDoc.documentID,
          imageUrls: imageUrls,
          name: (members != null)
              ? _getChatNameByMembers(currentUserId, members)
              : '',
          text: (messageDocs.length > 0)
              ? (messageDocs[0].data['contentType'] == 'text')
                  ? messageDocs[0].data['content']
                  : messageDocs[0].data['contentType']
              : '',
          date: timeago.format((messageDocs.length > 0)
              ? messageDocs[0].data['date'].toDate()
              : DateTime.now()),
          hasUnreadMessages: hasUnreadMessages,
          members: members);
    }));
  }

  Future<Map> _updateUserChatIdsAndGetUpdatedMembers(
      String chatId, String userId, Map members) async {
    DocumentReference userDocRef =
        _firestore.collection('users').document(userId);
    DocumentSnapshot userSnapshot = await userDocRef.get();
    List<String> newChatIds = userSnapshot.data['chatIds'].cast<String>();
    newChatIds.add(chatId);
    await userDocRef.updateData({'chatIds': newChatIds});
    members[userId] = {
      'username': userSnapshot.data['username'],
      'imageUrl': userSnapshot.data['imageUrl']
    };
    return members;
  }

  Future<List<DocumentSnapshot>> _getUsersDocsByQuery(String query) async {
    var usersQuery = _firestore.collection('users');
    if (query.isNotEmpty) {
      query = query.toLowerCase();
      usersQuery = usersQuery.where('searchTerms', arrayContains: query);
    }
    return (await usersQuery.getDocuments()).documents;
  }

  String _getChatNameByMembers(String currentUserId, Map members) {
    List<String> membersNames = [];
    String chatName = '';
    members.forEach((key, value) {
      if (key != currentUserId) membersNames.add(value['username']);
    });
    if (membersNames.length > 1)
      chatName = membersNames.sublist(0, 2).join(', ');
    else
      chatName = membersNames.join(', ');
    if (membersNames.length > 2)
      chatName += ' and ${membersNames.length - 2} other(s)';
    return chatName;
  }

  Future<void> _updateChatMembers(String chatId, Map members) {
    return _firestore
        .collection('chats')
        .document(chatId)
        .updateData({'members': members});
  }

  Future<List<ChatModel>> _getChatsByIds(List<String> chatIds) async {
    QuerySnapshot chatsSnapshot = await _firestore
        .collection('chats')
        .where(FieldPath.documentId, whereIn: chatIds)
        .getDocuments();
    return _getChatsByDocs(chatsSnapshot.documents);
  }

  Future<List<String>> _getCurrentUserChatIds() async {
    String currentUserId = await _authService.getCurrentUserId();
    DocumentSnapshot currentUserSnapshot =
        await _firestore.collection('users').document(currentUserId).get();
    return currentUserSnapshot.data['chatIds'].cast<String>();
  }
}

Future<void> openFile(String content) async {
  Dio dio = Dio();
  await PermissionHandler().requestPermissions([
    PermissionGroup.storage,
  ]);
  String path = (await getApplicationDocumentsDirectory()).path +
      "/" +
      content.substring(content.lastIndexOf("%2F") + 3, content.indexOf("?"));

  if (!await io.File(path).exists()) {
    Response result = await dio.download(content, path);
  }
  OpenFile.open(path);
}
