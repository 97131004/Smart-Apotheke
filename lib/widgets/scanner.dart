import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maph_group3/util/load_bar.dart';
import 'package:mlkit/mlkit.dart';
import 'package:maph_group3/widgets/image_preview.dart';
import 'package:maph_group3/util/helper.dart';
import 'med_scan.dart';
import '../util/nampr.dart';
import '../data/med.dart';

class Scanner extends StatefulWidget {
  Scanner({Key key}) : super(key: key);
  static bool imageloaddone = false;
  static Uint8List image;
  @override
  State<StatefulWidget> createState() {
    return _ScannerState();
  }
}

class _ScannerState extends State<Scanner> {
  static List<Med> medicaments;

  @override
  void initState() {
    super.initState();
  }

  File _file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Rezept scannen'),
        ),
        body: Scanner.imageloaddone ? loadbar() : loadImage());
  }

  Widget loadImage() {
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

  Future analyzeImage() async {
    try {
      FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;
      var currentLabels = await detector.detectFromBinary(Scanner.image);
      medicaments = await pznSearch(currentLabels);
      setState(() {
        gotoMedListFound();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  bool analyzeStart = false;
  Widget loadbar() {
    if (!analyzeStart) {
      analyzeImage();
      analyzeStart = true;
    }
    return LoadBar.build();
  }
//ImageProvider provider;

  void getImagefromGallery() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.gallery);
      if (file.existsSync()) {
        //  provider = ExtendedFileImageProvider(file);
        Scanner.image = file.readAsBytesSync();
        gotoPreview();
        analyzeStart = false;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void getImagefromCamera() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.camera);
      if (file.existsSync()) {
        Scanner.image = file.readAsBytesSync();
        gotoPreview();
        analyzeStart = false;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<List<Med>> pznSearch(List<VisionText> texts) async {
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
          if ((!Helper.isNumeric(acuChar) && !(acuChar == ' ')) ||
              (acuChar == '\n')) {
            break;
          } else if (Helper.isNumeric(acuChar)) pznNr += acuChar;
          if (pznNr.length == 8) break;
        }
        pznNrs.add(Med('', pznNr));
        text = text.substring(i + 1, text.length);
      }
    }
    return pznNrs;
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

  void gotoPreview() {
    Navigator.push(
        context,
        NoAnimationMaterialPageRoute(
          builder: (context) => ImgPreview(
              //provider: provider,
              // img:  Scanner.image
              ),
        ));
  }
}
