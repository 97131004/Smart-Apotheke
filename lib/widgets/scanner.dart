import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maph_group3/util/load_bar.dart';
import 'package:mlkit/mlkit.dart';
import 'package:image_editor/image_editor.dart';
import 'package:maph_group3/util/helper.dart';
import 'med_scan.dart';
import '../util/nampr.dart';
import '../data/med.dart';

class Scanner extends StatefulWidget {
  Scanner({Key key}) : super(key: key);
  static bool imageloaddone = false;
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

  Uint8List image;
  int rot = 0;
  bool imagechoosed = false;

  @override
  Widget build(BuildContext context) {
    if (!imagechoosed)
     return buildChooseImage();
    else
     return buildPreview(image);
  }

  Widget buildChooseImage() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Rezept scannen'),
        ),
        body: Scanner.imageloaddone ? LoadBar.build() : loadImage());
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

  Widget buildPreview(Uint8List rotateImg) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Vorschau'),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            FittedBox(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3 * 2,
                child: RotatedBox(
                  quarterTurns: rot,
                  child: Image.memory(
                    rotateImg,
                    scale: 1.0,
                    filterQuality: FilterQuality.none,
                    alignment: Alignment.center,
                    repeat: ImageRepeat.noRepeat,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(children: <Widget>[
                  IconButton(
                    alignment: Alignment.topLeft,
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        imagechoosed = false;
                      });
                    },
                    iconSize: 40,
                  )
                ]),
                Column(children: <Widget>[
                  IconButton(
                    alignment: Alignment.topLeft,
                    icon: Icon(Icons.rotate_right),
                    onPressed: () {
                      setState(() {
                        if (rot == 3) {
                          rot = 0;
                        } else {
                          rot += 1;
                        }
                        print(rot);
                      });
                    },
                    iconSize: 60,
                  )
                ]),
                Column(children: <Widget>[
                  IconButton(
                    alignment: Alignment.topRight,
                    icon: Icon(Icons.check),
                    onPressed: () => backtoScanner(),
                    iconSize: 50,
                  )
                ]),
              ],
            )
          ],
        )));
  }

  void backtoScanner() async {
    ImageEditorOption option = ImageEditorOption();
    option.addOption(RotateOption(rot * 90));

    image =
        await ImageEditor.editImage(image: image, imageEditorOption: option);
    analyzeImage();
    //Navigator.pop(context);
    setState(() {
      Scanner.imageloaddone = true;
      imagechoosed = false;
    });
  }

  Future analyzeImage() async {
    try {
      FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;
      var currentLabels = await detector.detectFromBinary(image);
      medicaments = await pznSearch(currentLabels);
      gotoMedListFound();
    } catch (e) {
      print(e.toString());
    }
  }

  void getImagefromGallery() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.gallery);
      if (file.existsSync()) {
        //  provider = ExtendedFileImageProvider(file);
        image = file.readAsBytesSync();
        setState(() {
          imagechoosed = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void getImagefromCamera() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.camera);
      if (file.existsSync()) {
        image = file.readAsBytesSync();
        setState(() {
          imagechoosed = true;
        });
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
}
