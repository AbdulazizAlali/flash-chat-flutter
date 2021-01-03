import 'package:flutter/material.dart';

class RawIconButton extends StatelessWidget {
  final double width;
  final double height;
  final EdgeInsets padding;
  final Color fillColor;
  final ShapeBorder shape;
  final Icon icon;
  final Function() onPressed;

  RawIconButton({
    this.width,
    this.height,
    this.padding,
    this.fillColor,
    this.shape,
    @required this.icon,
    @required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      constraints: BoxConstraints(
        minWidth: width ?? 0,
        minHeight: height ?? 0
      ),
      padding: padding ?? EdgeInsets.zero,
      fillColor: fillColor,
      shape: shape ?? RoundedRectangleBorder(),
      splashColor: Colors.transparent,
      child: icon,
      onPressed: onPressed
    );
  }
}