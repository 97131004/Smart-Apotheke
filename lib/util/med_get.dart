import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_pagewise/flutter_pagewise.dart';

import '../data/globals.dart' as globals;
import '../data/med.dart';
import 'helper.dart';

class MedGet {
  static Future<List<Med>> getMeds(
      String searchValue, int pageIndex, int pageCount) async {
    List<Med> list = new List<Med>();

    try {
      final resp = await http.get('https://www.docmorris.de/search?query="' +
          searchValue +
          '"&page=' +
          pageIndex.toString() +
          '&resultsPerPage=' +
          pageCount.toString());
      //print(resp.body);

      if (resp.statusCode == HttpStatus.ok) {
        String html = resp.body;

        List<String> pzns =
            Helper.parseMid(html, 'exactag.product_id = \'', '\';').split(',');

        if (pzns.length > 1) {
          //multi-page
          int searchIndex = 0;
          int index = 0;

          if (index == pzns.length - 1) return list;

          while (true) {
            searchIndex =
                html.indexOf('<span class="link name">', searchIndex + 1);
            if (searchIndex == -1) break;

            String medName = Helper.parseMid(
                html, '<span class="link name">', '</span>', searchIndex);

            //print(medName);

            if (index < pzns.length) {
              Med m = new Med(medName, pzns[index]);
              //print(pzns[index]);
              await MedGet.getMedInfo(m);
              if (m.name.length > 0 && m.pzn != '00000000') {
                list.add(m);
              }
              index++;
            }
          }
        } else if (pzns.length == 1) {
          //single-page
          String medName =
              Helper.parseMid(html, '<h1 itemprop="name">', '</h1>');
          Med m = new Med(medName, pzns[0]);
          await MedGet.getMedInfo(m);
          if (m.name.length > 0 && m.pzn != '00000000') {
            list.add(m);
          }
        }
      }
    } catch (err) {
      print('Caught error: $err');
    }

    return list;
  }

  static void getMedsPrefix(
      PagewiseLoadController plc, int pageIndex, String searchValue) {
    if (pageIndex == 0 && searchValue.length > 0) {
      //print(searchValue);

      //adding local search results on top
      List<Med> localMedsFound = globals.meds
          .where((item) =>
              item.name.toLowerCase().contains(searchValue.toLowerCase()))
          .toList();

      for (var i = 0; i < localMedsFound.length; i++) {
        plc.loadedItems.insert(i, localMedsFound[i]);
      }
    }
  }

  static Future<Med> getMedInfo(Med item) async {
    final resp = await http.get(
        'http://www.beipackzettel.de/search?utf8=%E2%9C%93&term=' + item.pzn);
    //print(resp.body);

    if (resp.statusCode == HttpStatus.ok) {
      String html = resp.body;

      String medName = Helper.parseMid(
          html, '<span class="hide-for-medium-down">', '</span>');
      if (medName.length > 0) {
        item.name = medName;
        //print(item.name);
      }

      String medUrl = Helper.parseMid(
          html,
          '<td class="medium-3 large-3 column"><a class="button" href="',
          '">Beipackzettel anzeigen</a></td>');
      if (medUrl.length > 0) {
        item.url = 'http://www.beipackzettel.de/' + medUrl;
        //print(item.url);
      }
    }

    return item;
  }

  static Future<String> getMedInfoData(Med item) async {
    try {
      final resp = await http.get(item.url);

      if (resp.statusCode == HttpStatus.ok) {
        String html = Helper.parseMid(
            resp.body, '<div class="content_area">', '<footer>');
        if (html.length > 0 &&
            html.indexOf('<p>Die gesuchte Seite wurde nicht gefunden. ' +
                    '<a href="/">Zur Startseite</a></p>') ==
                -1 &&
            html.indexOf('<h1>500 - Etwas lief schief</h1>') == -1 &&
            html.indexOf(
                    'Für dieses Arzneimittel ist momentan keine Patienteninformation ' +
                        'verfügbar. <a href="javascript:history.back()">Zurück</a>') ==
                -1) {
          html = html.replaceFirst(
              '<a href="#kapitelverzeichnis">Kapitelverzeichnis</a>', '');
          html = html.replaceFirst('<ul class="catalogue no-bullet">', '');

          return html;
        }
      }
    } catch (err) {
      print('Caught error: $err');
    }

    return null;
  }
}
