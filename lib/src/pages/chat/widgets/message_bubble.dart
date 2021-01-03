import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_firebase_chat/src/pages/image_view/image_view.dart';
import 'package:flutter_firebase_chat/src/services/chat_service.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';
import 'package:flutter_svg/svg.dart';

class MessageBubble extends StatefulWidget {
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
  MessageBubbleState createState() => MessageBubbleState();
}

class MessageBubbleState extends State<MessageBubble> {
  String loadingFile = "notloaded";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.contentType == "file") {
      io.File(widget.content).exists().then((value) {
        if (value) {
          loadingFile = "loaded";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    bool isCurrent = (widget.userId == null);
    BorderRadius bubbleBorderRadius = BorderRadius.only(
        topLeft: widget.withoutTopBorders
            ? (isCurrent ? Radius.circular(10) : Radius.zero)
            : Radius.circular(10),
        topRight: widget.withoutTopBorders
            ? (isCurrent ? Radius.zero : Radius.circular(10))
            : Radius.circular(10),
        bottomLeft: widget.withoutBottomBorders
            ? (isCurrent ? Radius.circular(10) : Radius.zero)
            : Radius.circular(10),
        bottomRight: widget.withoutBottomBorders
            ? (isCurrent ? Radius.zero : Radius.circular(10))
            : Radius.circular(10));
    double bubbleMaxWidth = (MediaQuery.of(context).size.width - 60) * 0.8;
    if (widget.withLeftOffset) bubbleMaxWidth = bubbleMaxWidth - 50;
    return Column(children: [
      (widget.newDay != null)
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Text(widget.newDay,
                  style: TextStyle(fontSize: 14, color: greyColor)))
          : Container(),
      Row(
          mainAxisAlignment:
              isCurrent ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.userImageUrl != null)
                ? Container(
                    margin: EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                        radius: 20,
                        backgroundColor: blueColor,
                        backgroundImage: NetworkImage(widget.userImageUrl)))
                : (widget.withLeftOffset
                    ? Container(width: 50, height: 50)
                    : Container()),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (widget.userName != null)
                      ? Container(
                          margin: EdgeInsets.only(bottom: 8),
                          child: Text(widget.userName,
                              style: TextStyle(fontSize: 15, color: greyColor)))
                      : Container(),
                  Container(
                    constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                    decoration: BoxDecoration(
                        color: (widget.contentType == 'image')
                            ? Colors.transparent
                            : (isCurrent ? blueColor : lightGreyColor),
                        borderRadius: bubbleBorderRadius),
                    padding: (widget.contentType == 'image')
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    margin: EdgeInsets.only(bottom: 8),
                    child: (widget.contentType == 'image')
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ImageViewPage(url: widget.content)));
                            },
                            child: ClipRRect(
                                borderRadius: bubbleBorderRadius,
                                child: Image.network(
                                  widget.content,
                                  fit: BoxFit.fitHeight,
                                  height: bubbleMaxWidth - 50,
                                )))
                        : (widget.contentType == 'file')
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FlatButton(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            widget.content.substring(
                                                widget.content
                                                        .lastIndexOf("%2F") +
                                                    3,
                                                widget.content.indexOf("?")),
                                            softWrap: true,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Color(0xEEFFFFFF),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SvgPicture.asset(
                                              widget.content.contains(".doc")
                                                  ? "assets/word.svg"
                                                  : widget.content
                                                          .contains(".ppt")
                                                      ? "assets/powerpoint.svg"
                                                      : widget.content
                                                              .contains(".xlsx")
                                                          ? "assets/excel.svg"
                                                          : widget.content
                                                                  .contains(
                                                                      ".pdf")
                                                              ? "assets/pdf.svg"
                                                              : "assets/file.svg",
                                              height: 30,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onPressed: () async {
                                      openFile(widget.content);
                                    },
                                  ),
                                  Text(
                                    widget.date,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: isCurrent
                                            ? Colors.white38
                                            : Colors.black38),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.content,
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: isCurrent
                                            ? whiteColor
                                            : blackColor),
                                  ),
                                  Text(
                                    widget.date,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: isCurrent
                                            ? Colors.white38
                                            : Colors.black38),
                                  ),
                                ],
                              ),
                  ),
                ])
          ])
    ]);
  }
}
