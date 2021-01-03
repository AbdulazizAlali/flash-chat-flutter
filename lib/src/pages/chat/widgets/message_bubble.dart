import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_firebase_chat/src/pages/image_view/image_view.dart';
import 'package:flutter_firebase_chat/src/services/chat_service.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {@required this.content,
      @required this.contentType,
      @required this.date,
      @required this.userId,
      @required this.userName,
      @required this.userImageUrl,
      @required this.withoutTopBorders,
      @required this.withoutBottomBorders,
      @required this.withLeftOffset,
      this.newDay});

  final String newDay;
  final String content;
  final String contentType;
  final String date;
  final String userId;
  final String userName;
  final String userImageUrl;
  final bool withoutTopBorders;
  final bool withoutBottomBorders;
  final bool withLeftOffset;

  @override
  Widget build(BuildContext context) {
    bool isCurrent = (userId == null);
    BorderRadius bubbleBorderRadius = BorderRadius.only(
        topLeft: withoutTopBorders
            ? (isCurrent ? Radius.circular(10) : Radius.zero)
            : Radius.circular(10),
        topRight: withoutTopBorders
            ? (isCurrent ? Radius.zero : Radius.circular(10))
            : Radius.circular(10),
        bottomLeft: withoutBottomBorders
            ? (isCurrent ? Radius.circular(10) : Radius.zero)
            : Radius.circular(10),
        bottomRight: withoutBottomBorders
            ? (isCurrent ? Radius.zero : Radius.circular(10))
            : Radius.circular(10));
    double bubbleMaxWidth = (MediaQuery.of(context).size.width - 60) * 0.7;
    if (withLeftOffset) bubbleMaxWidth = bubbleMaxWidth - 50;
    return Column(children: [
      (newDay != null)
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Text(newDay,
                  style: TextStyle(fontSize: 14, color: greyColor)))
          : Container(),
      Row(
          mainAxisAlignment:
              isCurrent ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (userImageUrl != null)
                ? Container(
                    margin: EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                        radius: 20,
                        backgroundColor: blueColor,
                        backgroundImage: NetworkImage(userImageUrl)))
                : (withLeftOffset
                    ? Container(width: 50, height: 50)
                    : Container()),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (userName != null)
                      ? Container(
                          margin: EdgeInsets.only(bottom: 8),
                          child: Text(userName,
                              style: TextStyle(fontSize: 15, color: greyColor)))
                      : Container(),
                  Container(
                    constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                    decoration: BoxDecoration(
                        color: (contentType == 'image')
                            ? Colors.transparent
                            : (isCurrent ? blueColor : lightGreyColor),
                        borderRadius: bubbleBorderRadius),
                    padding: (contentType == 'image')
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    margin: EdgeInsets.only(bottom: 8),
                    child: (contentType == 'image')
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ImageViewPage(url: content)));
                            },
                            child: ClipRRect(
                                borderRadius: bubbleBorderRadius,
                                child: Image.network(
                                  content,
                                  fit: BoxFit.fitHeight,
                                  height: bubbleMaxWidth - 50,
                                )))
                        : (contentType == 'file')
                            ? FlatButton(
                                child: Container(child: Icon(Icons.file_copy)),
                                onPressed: () async {
                                  openFile(content);
                                },
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    content,
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: isCurrent
                                            ? whiteColor
                                            : blackColor),
                                  ),
                                  Text(
                                    date,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: isCurrent
                                            ? Colors.white38
                                            : Colors.black38),
                                  ),
                                ],
                              ),
                  )
                ])
          ])
    ]);
  }
}
