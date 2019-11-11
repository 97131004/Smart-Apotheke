import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../util/med_list_core.dart';
import '../util/helper.dart';
import '../data/med.dart';

class MedListScan extends StatefulWidget {
  final List<Med> meds;

  MedListScan({Key key, @required this.meds}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MedListScanState();
  }
}

class _MedListScanState extends State<MedListScan> {
  bool getMedsDone = false;

  @override
  void initState() {
    super.initState();

    if (widget.meds != null && widget.meds.length > 0) {
      getMeds();
    } else {
      //
      print('no meds passed');
      //
    }
  }

  Future getMeds() async {
    for (int i = 0; i < widget.meds.length; i++) {
      final Med item = widget.meds[i];
      final resp = await http.get(
          'http://www.beipackzettel.de/search?utf8=%E2%9C%93&term=' + item.pzn);
      //print(resp.body);

      String html = resp.body;

      String medName = Helper.parseMid(
          html, '<span class="hide-for-medium-down">', '</span>');
      if (medName != "") {
        item.name = medName;
        //print(item.name);
      }

      String medUrl = Helper.parseMid(
          html,
          '<td class="medium-3 large-3 column"><a class="button" href="',
          '">Beipackzettel anzeigen</a></td>');
      if (medUrl != "") {
        item.url = 'http://www.beipackzettel.de/' + medUrl;
        //print(item.url);
      }
    }

    setState(() {
      getMedsDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gefundene Medikamente'),
      ),
      body: getMedsDone
          ? MedListCore.build(context, widget.meds)
          : Helper.buildLoadingBar(),
    );
  }
}
