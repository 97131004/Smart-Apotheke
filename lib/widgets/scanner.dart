import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maph_group3/util/load_bar.dart';
import 'package:maph_group3/util/no_internet_alert.dart';
import 'package:mlkit/mlkit.dart';
import 'package:image_editor/image_editor.dart';
import 'package:maph_group3/util/helper.dart';
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
  List<Med> _medicaments;
  bool _imageChosen = false;
  bool _imageLoaded = false;
  final _buttonHeight = 100.0;
  final _iconSize = 32.0;
  Uint8List _image;
  int _rotationQuarters = 0;

  @override
  void initState() {
     Helper.hasInternet().then((internet) {
      if (internet == null || !internet) {
        NoInternetAlert.show(context);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_imageChosen)
      return _buildChosenImage();
    else
      return _buildPreview(_image);
  }

  Widget _buildChosenImage() {
    return WillPopScope(
      onWillPop: () async {
        if (!_imageLoaded) {
          _imageChosen = false;
          Navigator.pop(context);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rezept scannen'),
        ),
        body: _imageLoaded ? LoadBar.build() : _buildImage(),
      ),
    );
  }

  Widget _buildNotification() {
    return Container(
      width: double.infinity,
      color: Colors.blueAccent,
      padding: EdgeInsets.all(15),
      child: Text(
        'Bitte beachten Sie, dass das Bild des Rezepts Pharmazentralnummern ' +
            '(PZN) enthält, waagerecht und scharf ist.',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: <Widget>[
        _buildNotification(),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 4, top: 4),
                child: ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width * 0.5 - 6,
                  height: _buttonHeight,
                  child: RaisedButton(
                    color: Theme.of(context).buttonColor,
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.folder,
                            color: Colors.white,
                            size: _iconSize,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            "Galerie",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: _getImagefromGallery,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4, top: 4),
                child: ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width * 0.5 - 6,
                  height: _buttonHeight,
                  child: RaisedButton(
                    color: Theme.of(context).buttonColor,
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: _iconSize,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            "Kamera",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: _getImagefromCamera,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPreview(Uint8List rotateImg) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Vorschau'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildNotification(),
            FittedBox(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3 * 2 - 60,
                child: RotatedBox(
                  quarterTurns: _rotationQuarters,
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
                        _imageChosen = false;
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
                        if (_rotationQuarters == 3) {
                          _rotationQuarters = 0;
                        } else {
                          _rotationQuarters += 1;
                        }
                      });
                    },
                    iconSize: 60,
                  )
                ]),
                Column(children: <Widget>[
                  IconButton(
                    alignment: Alignment.topRight,
                    icon: Icon(Icons.check),
                    onPressed: () => _backToScanner(),
                    iconSize: 50,
                  )
                ]),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _backToScanner() async {
    ImageEditorOption option = ImageEditorOption();
    option.addOption(RotateOption(_rotationQuarters * 90));

    _image =
        await ImageEditor.editImage(image: _image, imageEditorOption: option);
    _analyzeImage();
    setState(() {
      _imageLoaded = true;
      _imageChosen = false;
    });
  }

  Future _analyzeImage() async {
    try {
      FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;
      var currentLabels = await detector.detectFromBinary(_image);
      _medicaments = await _pznSearch(currentLabels);
      _gotoMedListFound();
    } catch (e) {
      print(e.toString());
    }
  }

  void _getImagefromGallery() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.gallery);
      if (file.existsSync()) {
        //  provider = ExtendedFileImageProvider(file);
        _image = file.readAsBytesSync();
        setState(() {
          _imageChosen = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _getImagefromCamera() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.camera);
      if (file.existsSync()) {
        _image = file.readAsBytesSync();
        setState(() {
          _imageChosen = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<List<Med>> _pznSearch(List<VisionText> texts) async {
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

  void _gotoMedListFound() {
    Navigator.push(
        context,
        NoAnimationMaterialPageRoute(
          builder: (context) => MedScan(
            meds: _medicaments,
          ),
        ));
    _imageChosen = false;
    _imageLoaded = false;
  }
}
