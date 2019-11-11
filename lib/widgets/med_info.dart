import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

import '../util/loading_bar.dart';
import '../util/helper.dart';
import '../data/med.dart';

class MedInfo extends StatefulWidget {
  final Med med;

  MedInfo({Key key, @required this.med}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MedInfoState();
  }
}

class _MedInfoState extends State<MedInfo> {
  bool getMedInfoDone = false;
  String medInfoData = '';
  List<GlobalKey> scrollKeys;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    getMedInfo();
  }

  Future getMedInfo() async {
    final resp = await http.get(widget.med.url);
    String html =
        Helper.parseMid(resp.body, '<div class="content_area">', '<footer>');
    if (html != '') {
      int chapterCount = '#chapter'.allMatches(html).length;

      scrollKeys = new List<GlobalKey>();
      for (int i = 0; i < chapterCount; i++) {
        scrollKeys.add(new GlobalKey());
      }

      html = html.replaceFirst(
          '<a href="#kapitelverzeichnis">Kapitelverzeichnis</a>', '');
      html = html.replaceFirst('<ul class="catalogue no-bullet">', '');

      medInfoData = html;
    } else {
      //error
    }

    setState(() {
      getMedInfoDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.med.name),
        ),
        body: getMedInfoDone
            ? Scrollbar(child: buildHtml())
            : LoadingBar.build(),
        floatingActionButton: Visibility(
          visible: getMedInfoDone,
          child: Container(
            height: 50.0,
            width: 50.0,
            child: FittedBox(
              child: FloatingActionButton(
                  foregroundColor: Colors.white,
                  child: Icon(Icons.arrow_upward),
                  onPressed: () => scrollController.jumpTo(0)),
            ),
          ),
        ));
  }

  Widget buildHtml() {
    return ListView(
      controller: scrollController,
      children: <Widget>[
        Html(
          data: medInfoData,
          padding: EdgeInsets.all(8.0),
          onLinkTap: (url) {
            //print("Opening URL: $url");
            if (url.startsWith('#chapter_')) {
              String ind = url.replaceAll('#chapter_', '');
              int iScrollKey = int.tryParse(ind);
              iScrollKey = iScrollKey - 1;
              if (iScrollKey >= 0 && iScrollKey < scrollKeys.length) {
                Scrollable.ensureVisible(scrollKeys[iScrollKey].currentContext);
              }
            }
          },
          useRichText: false,
          customRender: (node, children) {
            if (node is dom.Element) {
              if (node.id.startsWith('chapter_') && node.id != 'chapter_-1') {
                //chapter
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
                          fontSize: 16,
                        ),
                      )
                    ]);
              } else if (node.id == 'chapter_-1') {
                //title
                String html = node.innerHtml;
                if (html.length > 0 && html[0] == ' ') {
                  print(node.innerHtml);
                  node.innerHtml = html.replaceFirst(new RegExp(r"^\s+"), '') +
                      ' (PZN: ' +
                      widget.med.pzn +
                      ')';
                }
                return DefaultTextStyle(
                  child: Column(children: children),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                );
              } else if (node.className == 'accordion') {
                //links group
                return Container(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 25),
                  child: DefaultTextStyle(
                    child: Column(children: children),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              } else if (node.localName == 'li') {
                //each link from links group
                return Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Column(children: children),
                );
              } else if (node.className == 'catalogue no-bullet') {
                //links group subtopics (removing)
                node.remove();
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
