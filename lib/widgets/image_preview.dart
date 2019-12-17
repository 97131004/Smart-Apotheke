import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImgPreview extends StatefulWidget{

  final File img;
  ImgPreview({Key key, @required this.img}) : super (key : key);
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ImgPreview();
  }
  
}
class _ImgPreview extends State<ImgPreview>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(appBar: AppBar(
      title: Text('Vorschau'),
      actions: <Widget>[
        IconButton(icon: Icon(Icons.check),
        onPressed: ()=>backtoScanner(),)
      ],
    ),
    body: Column(
      children: <Widget>[ Expanded(
        child: Container(alignment: Alignment.center,
        child: Image.file(widget.img),)
      ), 
     FloatingActionButton(
       child: Icon(Icons.rotate_right),
       onPressed: () => rotate(),
     )],
     
    ));;

  }
  void rotate()
  {

  }
  void backtoScanner()
  {

  }
}