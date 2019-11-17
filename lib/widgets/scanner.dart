import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';

import 'med_scan.dart';
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
                    icon: Image.asset(
                      'images/gallery.jpg',
                      width: 100,
                      height: 100,
                    ),
                    textColor: Colors.black,
                    color: Colors.yellow,
                    onPressed: () => getImagefromGallery(),
                    label: new Text("Gallery"),
                  ),
                  RaisedButton.icon(
                    icon: Image.asset(
                      'images/camera.png',
                      width: 100,
                      height: 100,
                    ),
                    onPressed: () => getImagefromCamera(),
                    textColor: Colors.black,
                    color: Colors.redAccent,
                    label: new Text(
                      "Camera",
                    ),
                  ),
                ],
              )),
        ));
  }

  void getImagefromGallery() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        _file = file;
      });
      try {
        var currentLabels = await detector.detectFromPath(_file?.path);
        setState(() {
          _currentLabels = currentLabels;
        });
        gotoMedListFound();
      } catch (e) {
        print(e.toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void getImagefromCamera() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.camera);
      setState(() {
        _file = file;
      });
      try {
        var currentLabels = await detector.detectFromPath(_file?.path);
        setState(() {
          _currentLabels = currentLabels;
        });
        gotoMedListFound();
      } catch (e) {
        print(e.toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void gotoMedListFound() {
    Navigator.push(
        context,
        NoAnimationMaterialPageRoute(
          builder: (context) => textfound(
            labels: _currentLabels,
          ),
           
        ));
  }
}

//show the found texts (just to test)
class textfound extends StatelessWidget {
  List<VisionText> labels;
  textfound({Key key, @required this.labels}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PZN List"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      child: Column(
        children: <Widget>[
          //_buildImage(),
          _buildList(labels)
        ],
      ),
    );
  }

  Widget _buildList(List<VisionText> texts) {
    List<String> pznList = pznSearch(texts);
    if (texts.length == 0) {
      return Text('empty');
    }
    return Expanded(
      child: Container(
        child: ListView.builder(
          padding: const EdgeInsets.all(1.0),
          itemCount: pznList.length,
          itemBuilder: (context, i) {
            return _buildRow(pznList[i]);
          },
        ),
      ),
    );
  }

  Widget _buildRow(String text) {
    return ListTile(
      title: Text(text),
      dense: true,
    );
  }

  List<String> pznSearch(List<VisionText> texts) {
    List<String> pznNrs = [];
    for (var item in texts) {
      String text = item.text ;
      text = text.toUpperCase().replaceAll(' ', '');
      while (text.contains("PZN")) {
        text = text.replaceAll(':', '');
        int pos = text.indexOf("PZN");
        String pznNr = text.substring(pos + 3, pos + 11);
        if (!isNumeric(pznNr)) {
          pznNr = pznNr.replaceAll(new RegExp('[a-zA-Z]'), '');
        }
        pznNrs.add(pznNr);
        text = text.substring(pos + pznNr.length + 3, text.length);
      }
    }
    return pznNrs;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}
