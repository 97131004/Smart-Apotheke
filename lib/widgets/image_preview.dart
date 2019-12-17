import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';
import 'package:maph_group3/widgets/scanner.dart';

class ImgPreview extends StatefulWidget {
  //Uint8List img;
 // ImgPreview({Key key, @required this.img}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ImgPreview();
  }
}

class _ImgPreview extends State<ImgPreview> {
  Uint8List img;
   @override
  void initState() {
    super.initState();
    img = Scanner.image;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Vorschau'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () => backtoScanner(),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: Container(
              alignment: Alignment.center,
              child: Image.memory(img),
            )),
            FloatingActionButton(
              child: Icon(Icons.rotate_right),
              onPressed: () => rotate(),
            )
          ],
        ));
  }

  Future rotate() async {
    ImageEditorOption option = ImageEditorOption();
    option.addOption(RotateOption(90));

    var rotateImg = await ImageEditor.editImage(
        image: img, imageEditorOption: option);
    setState(() {
      img = rotateImg;
    });
  }

  void backtoScanner() {
    Scanner.image  = img;
    Navigator.pop(context);
    setState(() {
      Scanner.imageloaddone = true;
    });
  }
}
