import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import '../util/helper.dart';
import '../util/no_internet_alert.dart';
import '../util/med_get.dart';
import '../util/load_bar.dart';
import '../data/med.dart';

/// Page that shows medicament information from the package leaflet. Loads the information 
/// with a GET-Request from [beipackzettel.de], then parses and displays it here. You can jump
/// (autoscroll) to certain categories by clicking on the links at the top. The user can
/// increase and decrease the text size.
class MedInfo extends StatefulWidget {
  final Med med;

  MedInfo({Key key, @required this.med}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MedInfoState();
  }
}

class MedInfoState extends State<MedInfo> {
  /// [true] when [getMedInfoData] finished loading medicament information.
  bool getMedInfoDataDone = false;

  /// Storing retrieved medicament information text.
  String medInfoData = '';

  /// List of keys which represent the anchors to jump to.
  List<GlobalKey> scrollKeys;

  ScrollController scrollController;

  /// Dynamic size variable, that is added to the corresponding text sizes.
  double varSize = 0;

  bool varSizeLoaded = false;
  String saveKeyMedInfoTextSize = 'medInfoTextSize';

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

    scrollController = ScrollController();
    getMedInfoDataInit();
  }

  /// Retrieving medicament information.
  void getMedInfoDataInit() {
    setState(() {
      getMedInfoDataDone = false;
    });
    if (widget.med.url.length > 0) {
      getMedInfoData();
    } else {
      /// Empty [medInfoData] shows error note.
      medInfoData = '';
      setState(() {
        getMedInfoDataDone = true;
      });
    }
  }

  /// Retrieving medicament information from web and generating correct amount
  /// of anchors depending on page's category count.
  Future getMedInfoData() async {
    String resp = await MedGet.getMedInfoData(widget.med);

    if (resp != null && resp.length > 0) {
      medInfoData = resp;
      int chapterCount = '#chapter'.allMatches(medInfoData).length;

      scrollKeys = new List<GlobalKey>();
      for (int i = 0; i < chapterCount; i++) {
        scrollKeys.add(new GlobalKey());
      }
    } else {
      /// Empty [medInfoData] shows error note.
      medInfoData = '';
    }

    if (medInfoData.length > 0) {
      loadMedInfoTextSize();
    }

    if (this.mounted) {
      setState(() {
        getMedInfoDataDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        saveMedInfoTextSize();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.med.name),
          actions: <Widget>[
            if (getMedInfoDataDone && medInfoData.length > 0)
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.zoom_in),
                    onPressed: () {
                      /// Increasing text size.
                      if (varSize < 6) {
                        setState(() {
                          varSize += 1;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.zoom_out),
                    onPressed: () {
                      /// Decreasing text size.
                      if (varSize > 0) {
                        setState(() {
                          varSize -= 1;
                        });
                      }
                    },
                  ),
                ],
              )
          ],
        ),
        body: getMedInfoDataDone
            ? ((medInfoData.length > 0) ? buildHtml() : buildNotFound())
            : LoadBar.build(),
        floatingActionButton: Visibility(
          visible: (getMedInfoDataDone && medInfoData.length > 0),
          child: FloatingActionButton(
            foregroundColor: Colors.white,
            child: Icon(Icons.arrow_upward),

            /// Jumping to the very top on floating button press.
            onPressed: () => scrollController.jumpTo(0),
          ),
        ),
      ),
    );
  }

  /// Visualization on no package leaflet found.
  Widget buildNotFound() {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Beipackzettel nicht gefunden.',
              textAlign: TextAlign.center,
            ),
          ),
          ButtonTheme(
            buttonColor: Theme.of(context).buttonColor,
            minWidth: MediaQuery.of(context).size.width * 0.75,
            height: 50.0,
            child: RaisedButton.icon(
              onPressed: getMedInfoDataInit,
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text("Nochmals versuchen",
                  style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  /// Visualization of retrieved package leaflet, and managing anchors and jump links.
  Widget buildHtml() {
    return Scrollbar(
      child: ListView(
        controller: scrollController,
        children: <Widget>[
          Html(
            data: medInfoData,
            padding: EdgeInsets.all(8.0),
            onLinkTap: (url) {
              /// Jump (autoscroll) to the corresponding anchor,
              /// which represents a category.
              if (url.startsWith('#chapter_')) {
                String ind = url.replaceAll('#chapter_', '');
                int iScrollKey = int.tryParse(ind);
                iScrollKey = iScrollKey - 1;
                if (iScrollKey >= 0 && iScrollKey < scrollKeys.length) {
                  Scrollable.ensureVisible(
                      scrollKeys[iScrollKey].currentContext);
                }
              }
            },
            useRichText: false,
            customRender: (node, children) {
              /// Iterating through retrieved [medInfoData] DOM (Document Object Model).
              if (node is dom.Element) {
                if (node.id.startsWith('chapter_') && node.id != 'chapter_-1') {
                  /// Visualizing chapter title and applying [scrollKeys] to set anchors.
                  String id = node.id;
                  String ind = id.replaceAll('chapter_', '');
                  int iScrollKey = int.tryParse(ind);
                  iScrollKey = iScrollKey - 1;
                  if (!(iScrollKey >= 0 && iScrollKey < scrollKeys.length)) {
                    iScrollKey = null;
                  }
                  return Column(
                      key: (scrollKeys != null && iScrollKey != null)
                          ? scrollKeys[iScrollKey]
                          : null,
                      children: <Widget>[
                        DefaultTextStyle(
                          child: Column(children: children),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                Theme.of(context).textTheme.body2.fontSize +
                                    varSize,
                          ),
                        )
                      ]);
                } else if (node.id == 'chapter_-1') {
                  /// Visualizing medicament title.
                  String html = node.innerHtml;
                  if (html.length > 0 && html[0] == ' ') {
                    node.innerHtml = html
                            .replaceAll('?', '')
                            .replaceAll('"', "")
                            .replaceAll('Patienteninformation für', '')
                            .replaceFirst(new RegExp(r"^\s+"), '') +
                        ' (PZN: ' +
                        widget.med.pzn +
                        ')';
                  }
                  return DefaultTextStyle(
                    child: Column(children: children),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.title.fontSize + varSize,
                    ),
                  );
                } else if (node.className == 'accordion') {
                  /// Visualizing category jump links group (on top).
                  return Container(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 25),
                    child: DefaultTextStyle(
                      child: Column(children: children),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context).textTheme.body2.fontSize +
                            varSize,
                      ),
                    ),
                  );
                } else if (node.localName == 'li') {
                  /// Visualizing each link from category jump links group.
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Column(children: children),
                  );
                } else if (node.className == 'catalogue no-bullet') {
                  /// Removing each subcategory from category jump links group.
                  node.remove();
                } else if (node.className == 'infobox') {
                  /// Visualizing content (information) text.
                  return DefaultTextStyle(
                    child: Column(children: children),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize:
                          Theme.of(context).textTheme.body2.fontSize + varSize,
                    ),
                  );
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future loadMedInfoTextSize() async {
    String val = await Helper.readDataFromsp(saveKeyMedInfoTextSize);
    if (val.isNotEmpty) {
      double size = double.tryParse(val);
      if (size != null) {
        setState(() {
          varSize = size;
        });
        varSizeLoaded = true;
      }
    }
  }

  Future saveMedInfoTextSize() async {
    if (varSizeLoaded) {
      await Helper.writeDatatoSp(saveKeyMedInfoTextSize, varSize.toString());
    }
  }
}
