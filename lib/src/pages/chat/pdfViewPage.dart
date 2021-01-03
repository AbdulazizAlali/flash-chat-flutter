import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PdfViewPage extends StatefulWidget {
  static String id = "PdfView";
  PdfViewPage(this.path);
  String path;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PdfViewPage> {
  int _actualPageNumber = 1, _allPagesCount = 0;
  bool isSampleDoc = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      constraints: BoxConstraints.expand(),
      child: Center(
          child: Stack(
        children: <Widget>[
          PDF().cachedFromUrl(
            widget.path,
            placeholder: (progress) => Center(child: Text('$progress %')),
            errorWidget: (error) => Center(child: Text(error.toString())),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: new BoxDecoration(
                    color: Colors.blueGrey.shade500,
                    borderRadius: new BorderRadius.all(Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_actualPageNumber/${_allPagesCount}',
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
          ),
        ],
      )),
    ));
  }
}
