import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';


import 'med_list_scan.dart';
import '../util/nampr.dart';
import '../data/med.dart';

class Scanner extends StatefulWidget {
  Scanner({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ScannerState();
  }
}

class _ScannerState extends State<Scanner> {
  List<Med> medicaments = [
    Med('optionaler_name_oder_leerer_string', '10019621'),
    Med('optionaler_name_oder_leerer_string', '01502726'),
    Med('', 'test'),
    Med('', '00000000'),
    Med('optionaler_name_oder_leerer_string', '01343682')
  ];

  @override
  void initState() {
    super.initState();
  }
File _file;
  List<VisionText> _currentLabels = [];
  FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Rezept scannen'),
        ),
        body: Center(
          child: Container(
            alignment: Alignment.center,
              //Text('Hier die Rezept-/Texterkennung durch Kamera'),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton.icon(
                    icon:  Image.asset('images/gallery.jpg' ,width: 100,height: 100,) ,
                    textColor: Colors.black,
                    color: Colors.yellow,
                    onPressed: ()=> getImagefromGallery(),
                    label: new Text("Gallery"),
                  ),
                  RaisedButton.icon(
                    icon:  Image.asset('images/camera.png' ,width: 100,height: 100,) ,
                    onPressed: () => getImagefromCamera(),
                    textColor: Colors.black,
                    color: Colors.redAccent,
                    label: new Text(
                      "Camera",
                    ),
                  ),
                ],
              )
          ),
        ));
  }
  
  void getImagefromGallery() async{
      try{
        var file = await ImagePicker.pickImage(
            source: ImageSource.gallery
        );
        setState(() {
            _file = file; 
        });
        try{
          var currentLabels = await detector.detectFromPath  (_file?.path);
          setState(() {
           _currentLabels = currentLabels; 
          });
          gotoMedListFound();
        }
        catch(e){
          print(e.toString());
        }
      }
      catch(e){
          print(e.toString());
      }
  }
  void getImagefromCamera() async{
    try{
        var file = await ImagePicker.pickImage(
            source: ImageSource.camera
        );
        setState(() {
            _file = file; 
        });
        try{
          var currentLabels = await detector.detectFromPath(_file?.path);
          setState(() {
           _currentLabels = currentLabels; 
          });
          gotoMedListFound();
        }
        catch(e){
          print(e.toString());
        }
      }
      catch(e){
          print(e.toString());
      }
  }
  void gotoMedListFound() {
    Navigator.push(
      context,
      NoAnimationMaterialPageRoute(
         builder: (context) => textfound(labels: _currentLabels,),
      )
    );
  }
 
}


//show the found texts (just to test)
class textfound extends StatelessWidget{
   List<VisionText> labels;
   textfound({Key key, @required this.labels}) : super(key: key);
  @override
  Widget build(BuildContext context ) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: _buildBody(),
    );
  }

    Widget _buildBody(){
    return Container(
      child: Column(children: <Widget>[
        //_buildImage(),
        _buildList(labels)
      ],),);
  }
  Widget _buildList(List<VisionText> texts)
  {
    if(texts.length == 0){
      return Text('empty');
    }
    return Expanded(
      child: Container(child: ListView.builder(
        padding: const EdgeInsets.all(1.0),
        itemCount: texts.length,
        itemBuilder: (context, i){
          return _buildRow(texts[i].text);
        },
      ),),
    );
  }

  Widget _buildRow(String text){
    return ListTile(
      title: Text(
        "Text: ${text}"
      ),
      dense: true,
    );
  }
}