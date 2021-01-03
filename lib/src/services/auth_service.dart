import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_chat/src/pages/profile/profile.dart';

class AuthService {
  Firestore _firestore = Firestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> login(
    String email,
    String password
  ) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
  }

  Future<void> register(
    String username,
    String email,
    String password,
    File imageFile
  ) async {
    AuthResult authResult = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    StorageReference firebaseStorageRef = _firebaseStorage.ref().child(
      _getUserImagePath(authResult.user.uid)
    );
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    String imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

    return _firestore
      .collection('users')
      .document(authResult.user.uid)
      .setData({
        'username': username,
        'email': email,
        'imageUrl': imageUrl,
        'chatIds': [],
        'searchTerms': _getSearchTermsByString(username)
      });
  }

  Future<ProfileModel> getProfile() async {
    String currentUserId = await getCurrentUserId();
    DocumentSnapshot profileDoc = await _firestore.collection('users').document(currentUserId).get();
    return ProfileModel.fromJson(profileDoc.data);
  }

  Future<void> updateProfile(
    ProfileModel profileData
  ) async {
    FirebaseUser currentUser = await _firebaseAuth.currentUser();

    if (profileData.password.isNotEmpty)
      await currentUser.updatePassword(profileData.password);

    if (profileData.imageFile != null) {
      StorageReference firebaseStorageRef = _firebaseStorage.ref().child(
        _getUserImagePath(currentUser.uid)
      );
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(profileData.imageFile);
      profileData.imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    }

    return _firestore
      .collection('users')
      .document(currentUser.uid)
      .updateData({
        'username': profileData.username,
        'imageUrl': profileData.imageUrl,
        'searchTerms': _getSearchTermsByString(profileData.username)
      });
  }

  Future<void> logout() {
    return _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) {
    return _firebaseAuth.sendPasswordResetEmail(
      email: email
    );
  }

  Future<bool> isLoggedIn() async {
    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<String> getCurrentUserId() async {
    return (await _firebaseAuth.currentUser()).uid;
  }

  String _getUserImagePath(String userId) {
    return 'users/' +
      userId +
      DateTime.now().millisecondsSinceEpoch.toString() +
      '.jpg';
  }

  List<String> _getSearchTermsByString(String source) {
    source = source.trim();
    List<String> longTerms = source
      .split(' ')
      .map((term) => term.toLowerCase())
      .toList();
    List<String> shortTerms = [];
    longTerms.forEach((longTerm) {
      for (int i = 0; i < longTerm.length; i++) {
        shortTerms.add(longTerm.substring(0, i + 1));
      }
    });
    return shortTerms;
  }
}