import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';
import 'package:flutter_firebase_chat/src/widgets/raw_icon_button.dart';

class SearchBarTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool showClear;
  final Function() onClearPressed;
  final Function() onChanged;
  final Function() onChangedWithDelay;  

  SearchBarTextField({
    @required this.hintText,
    @required this.controller,
    @required this.showClear,
    @required this.onClearPressed,
    @required this.onChanged,
    @required this.onChangedWithDelay
  });

  @override
  SearchBarTextFieldState createState() => SearchBarTextFieldState();
}

class SearchBarTextFieldState extends State<SearchBarTextField> {
  Timer _searchBarDebounceTimer;

  @override
  void dispose() {
    _searchBarDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 26),
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: lightGreyColor
      ),
      child: Row(children: [
        Icon(
          Icons.search,
          color: greyColor,
          size: 20,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10),
            child: TextField(
              style: TextStyle(
                fontSize: 16,
                color: blackColor
              ),
              controller: widget.controller,
              onChanged: (_) {
                widget.onChanged();
                if (_searchBarDebounceTimer?.isActive ?? false)
                  _searchBarDebounceTimer.cancel();
                _searchBarDebounceTimer = Timer(
                  Duration(milliseconds: 1000), () =>
                    widget.onChangedWithDelay()
                );
              },
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: greyColor
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none
              )
            )
          )
        ),
        widget.showClear ? RawIconButton(
          height: 32,
          padding: EdgeInsets.symmetric(horizontal: 10),
          icon: Icon(
            Icons.cancel,
            color: greyColor,
            size: 20
          ),
          onPressed: widget.onClearPressed
        ) : Container()
      ])
    );
  }
}