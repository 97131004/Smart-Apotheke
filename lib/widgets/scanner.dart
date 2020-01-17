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

/// Page to manage the scanning of the medical prescription. User can choose whether he wants
/// to scan an existing image from the phone's storage, or scan the image using the phone's 
/// camera. The user is then prompted to accept, decline or rotate the image by 90 degrees, 
/// so it appears to be horizontal (required for proper text recognition).
///
/// Afterwards, the scanning process begins. The scanning basically uses
/// the cloud-based text recognition API from the machine learning kit for firebase
/// (https://firebase.google.com/docs/ml-kit/android/recognize-text?hl=de).
/// Since firebase is a cloud-based service, the text recognition
/// requires an internet connection and a linked google account
/// (https://github.com/azihsoyn/flutter_mlkit#android-integration).
/// The linked google account and corresponding API keys are stored in
/// [android\app\google-services.json].
///
/// The text recognition library then outputs all found text pieces,
/// where we search for the medicament [pzn] ('PZN') text and parse
/// the actual [pzn] number after it.

class Scanner extends StatefulWidget {
  Scanner({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ScannerState();
  }
}

class _ScannerState extends State<Scanner> {
  /// List of found medicaments (only includes [pzn]'s) to be later
  /// passed to the [med_scan] page.
  List<Med> _medicaments;

  /// Flag whether an image has been chosen from the gallery or camera.
  bool _imageChosen = false;

  /// Flag whether an image is currently being processed.
  bool _imageLoading = false;

  /// Storing processed image.
  Uint8List _image;

  /// Storing amount of quarter turns done by the user.
  int _rotationQuarters = 0;

  @override
  void initState() {
    /// Checks for internet connection. If there's no connection, a
    /// [no_internet_alert] will be shown.
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
      return _buildMain();
    else
      return _buildPreview(_image);
  }

  /// Displays the [_buildMenu] overview with the gallery and camera buttons,
  /// and the loading bars while the image is processed.
  Widget _buildMain() {
    return WillPopScope(
      onWillPop: () async {
        if (!_imageLoading) {
          Navigator.pop(context);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rezept scannen'),
        ),
        body: _imageLoading ? LoadBar.build() : _buildMenu(),
      ),
    );
  }

  /// Displays the top note.
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

  /// Displays the overview with the gallery and camera buttons.
  Widget _buildMenu() {
    return Stack(
      children: <Widget>[
        _buildNotification(),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildButton('Galerie', Icons.folder, _getImagefromGallery),
              _buildButton('Kamera', Icons.camera_alt, _getImagefromCamera),
            ],
          ),
        )
      ],
    );
  }

  /// Visualizing main button.
  Widget _buildButton(String label, IconData icon, Function funcOnPressed) {
    return Padding(
      padding: EdgeInsets.only(left: 4, top: 4),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width * 0.5 - 6,
        height: 100.0,
        child: RaisedButton(
          color: Theme.of(context).buttonColor,
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            if (funcOnPressed != null) funcOnPressed();
          },
        ),
      ),
    );
  }

  /// Displays the image preview.
  Widget _buildPreview(Uint8List rotateImg) {
    return WillPopScope(
      onWillPop: () async {
        if (!_imageLoading) {
          setState(() {
            _imageChosen = false;
          });
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Vorschau'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildNotification(),

              /// Needs a [SizedBox] inside a [FittedBox] and poor filter qualities in
              /// [Image.memory] for good performance and fast rotations.
              FittedBox(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3 * 2 - 60,
                  child: RotatedBox(
                    /// [RotatedBox] has a parameter to rotate the image by [quarterTurns].
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
                          /// Rotating image by the number of quarter turns.
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
                      onPressed: () => _processImage(),
                      iconSize: 50,
                    )
                  ]),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _getImagefromGallery() async {
    try {
      var file = await ImagePicker.pickImage(source: ImageSource.gallery);
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

  /// Processes the image.
  void _processImage() async {
    /// Refreshing UI to show loading bars.
    setState(() {
      _imageLoading = true;
      _imageChosen = false;
    });

    /// Applying correct number of quarter turn rotations to the [_image].
    ImageEditorOption option = ImageEditorOption();
    option.addOption(RotateOption(_rotationQuarters * 90));
    _image =
        await ImageEditor.editImage(image: _image, imageEditorOption: option);

    /// Finding all [pzn]'s in the image.
    _analyzeImage();
  }

  /// Analyzes the image by initializing a firebase object, linking the image
  /// and finding the [pzn] numbers.
  Future _analyzeImage() async {
    try {
      FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;
      var currentLabels = await detector.detectFromBinary(_image);
      _medicaments = await _findPzn(currentLabels);
      _gotoMedScan();
    } catch (e) {
      print(e.toString());
    }
  }

  /// First searches for the 'PZN' text, then parses the actual [pzn] number after it.
  /// Then stores all found [pzn]'s in a list of [med] objects 
  /// (each of them only including a [pzn] number).
  Future<List<Med>> _findPzn(List<VisionText> texts) async {
    List<Med> pznNrs = [];
    for (var item in texts) {
      String text = item.text;
      text = text.toUpperCase();
      while (text.contains('PZN')) {
        text = text.replaceAll(':', '');
        int pos = text.indexOf('PZN');
        String pznNr = '';
        int i;
        for (i = pos + 3; i <= text.length; i++) {
          String acuChar = text[i];
          if ((!Helper.isInteger(acuChar) && !(acuChar == ' ')) ||
              (acuChar == '\n')) {
            break;
          } else if (Helper.isInteger(acuChar)) pznNr += acuChar;
          if (pznNr.length == 8) break;
        }
        pznNrs.add(Med('', pznNr));
        text = text.substring(i + 1, text.length);
      }
    }
    return pznNrs;
  }

  /// Pushes to [med_scan] page with a list of [med]'s including the found [pzn] numbers.
  void _gotoMedScan() {
    Navigator.push(
        context,
        NoAnimationMaterialPageRoute(
          builder: (context) => MedScan(
            meds: _medicaments,
          ),
        ));
    _imageChosen = false;
    _imageLoading = false;
  }
}
