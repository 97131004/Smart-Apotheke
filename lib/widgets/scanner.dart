import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maph_group3/data/globals.dart' as prefix0;
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
  List<Med> medicaments;

  @override
  void initState() {
    super.initState();
  }

  File _file;
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
                      'assets/gallery.jpg',
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
                      'assets/camera.png',
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
        var results = await pznSearch(currentLabels);
        setState(() {
          medicaments = results;
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
        var results = await pznSearch(currentLabels);
        setState(() {
          medicaments = results;
        });
        gotoMedListFound();
      } catch (e) {
        print(e.toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<Med>> pznSearch(List<VisionText> texts) async {
    List<Med> pznNrs = [];
    for (var item in texts) {
      String text = item.text;
      text = text.toUpperCase();
      while (text.contains("PZN")) {
        text = text.replaceAll(':', '');
        int pos = text.indexOf("PZN");
        String pznNr = '';
        int i;
        for (i = pos + 3; i <= text.length; i++) {
          String acuChar = text[i];
          if ((!isNumeric(acuChar) && !(acuChar == ' '))||(acuChar == '\n') ) {
            break;
          }
          else if(isNumeric(acuChar))pznNr += acuChar;
          if(pznNr.length == 8) break;
        }
        pznNrs.add(Med('', pznNr));
        text = text.substring(i+1, text.length);
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

  void gotoMedListFound() {
    Navigator.push(
        context,
        NoAnimationMaterialPageRoute(
          builder: (context) => MedScan(
            meds: medicaments,
          ),
        ));
  }
}
