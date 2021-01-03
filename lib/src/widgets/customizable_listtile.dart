import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';

class CustomizableListTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget subTitle;
  final Widget trailing;
  final Function() onTap;

  CustomizableListTile({
    @required this.leading,
    @required this.title,
    this.subTitle,
    this.trailing,
    @required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      child: Container(
        height: 50,
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: 20),
              child: leading
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: (subTitle != null) ?
                  MainAxisAlignment.spaceEvenly :
                  MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: blackColor
                    )
                  ),
                  subTitle ?? Container()
                ]
              )
            ),
            (trailing != null) ? Container(
              margin: EdgeInsets.only(left: 20),
              child: trailing
            ) : Container()
          ]
        )
      ),
      onTap: onTap
    );
  }
}