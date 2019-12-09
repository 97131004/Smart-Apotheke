import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maph_group3/util/load_bar.dart';
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
        body: imageloaddone? LoadBar.buildwithtext("Scannt..."):loadImage());
  }
  bool imageloaddone = false;
  Widget loadImage()
  {
    return Center(
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
        );
  }
  Future analyzeImage() async
  {
     try {
        var currentLabels = await detector.detectFromPath(_file?.path);
        await pznSearch(currentLabels);
      } catch (e) {
        print(e.toString());
      }
  }
  void getImagefromGallery() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.gallery);
      if(file.existsSync()){setState(() {
        _file = file;
         analyzeImage();
        imageloaddone = true;
      });}
    
    } catch (e) {
      print(e.toString());
    }
  }

  void getImagefromCamera() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.camera);
     if(file.existsSync()){setState(() {
        _file = file;
         analyzeImage();
        imageloaddone = true;
      });}
    
       analyzeImage();
    } catch (e) {
      print(e.toString());
    }
  }

  Future pznSearch(List<VisionText> texts) async {
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
    setState(() {
      imageloaddone = false;
      medicaments = pznNrs;
      gotoMedListFound();
    });
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
