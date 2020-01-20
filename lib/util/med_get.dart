import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_pagewise/flutter_pagewise.dart';
import '../data/globals.dart' as globals;
import '../data/med.dart';
import 'helper.dart';

/// Interface logic class for medicament information retrieval in the app.
/// Functions to retrieve, handle and parse lists of medicaments from websites like 
/// [docmorris.de] (to get the [name] or [pzn] based on [name] or [pzn]) and 
/// [beipackzettel.de] (to get the package leaflet [url] based on [pzn]).

class MedGet {
  /// First sends a GET-Request with a search query to [docmorris.de]
  /// (including the [searchValue], [pageIndex], [resultsPerPage]),
  /// then gets a response, parses it to acquire the [pzn] and [name]. Then uses that [pzn]
  /// to search on [beipackzettel.de] with [getMedInfo] to acquire the package leaflet [url],
  /// then returns a list of found [med]'s. [isMedSearch] is true if search is done in
  /// [med_search], so it will skip returning entries that are already in the local
  /// [globals.recentMeds] list; those are shown with the [getMedsPrefix] function.
  static Future<List<Med>> getMeds(
      String searchValue, int pageIndex, int resultsPerPage,
      [bool isMedSearch = false]) async {
    List<Med> list = new List<Med>();

    try {
      final resp = await http.get('https://www.docmorris.de/search?query="' +
          searchValue +
          '"&page=' +
          pageIndex.toString() +
          '&resultsPerPage=' +
          resultsPerPage.toString());

      if (resp.statusCode == HttpStatus.ok) {
        String html = resp.body;

        List<String> pzns =
            Helper.parseMid(html, 'exactag.product_id = \'', '\';').split(',');

        if (pzns.length > 1) {
          /// Multi-page results.
          int searchIndex = 0;
          int index = 0;

          if (index == pzns.length - 1) return list;

          while (true) {
            /// Break if medicament is already in local [globals.recentMeds] list.
            if (isMedSearch && isMedInRecentMedsList(pzns[index])) break;

            searchIndex =
                html.indexOf('<span class="link name">', searchIndex + 1);

            /// Break if no medicaments found.
            if (searchIndex == -1) break;

            String medName = Helper.parseMid(
                html, '<span class="link name">', '</span>', searchIndex);

            if (index < pzns.length) {
              Med m = new Med(medName, pzns[index]);

              /// Retrieving package leaflet [url].
              await getMedInfo(m);
              if (m.name.length > 0 && m.pzn != '00000000') {
                list.add(m);
              }
              index++;
            }
          }
        } else if (pzns.length == 1) {
          /// Single-page results.
          if (!(isMedSearch && isMedInRecentMedsList(pzns[0]))) {
            String medName =
                Helper.parseMid(html, '<h1 itemprop="name">', '</h1>');
            Med m = new Med(medName, pzns[0]);

            /// Retrieving package leaflet [url].
            await getMedInfo(m);
            if (m.name.length > 0 && m.pzn != '00000000') {
              list.add(m);
            }
          }
        }
      }
    } catch (err) {
      print('Caught error: $err');
    }

    return list;
  }

  /// Returns whether a [med] with a certain [pzn] is found in the [globals.recentMeds] list.
  static bool isMedInRecentMedsList(String pzn) {
    return (globals.recentMeds
            .where((item) => item.pzn.toLowerCase().contains(pzn.toLowerCase()))
            .toList()
            .length !=
        0);
  }

  /// Adds local search results from the [globals.recentMeds] list (based on [name] or [pzn])
  /// to the [plc] in [med_search].
  static void getMedsPrefix(
      PagewiseLoadController plc, int pageIndex, String searchValue) {
    if (pageIndex == 0 && searchValue.length > 0) {
      List<Med> localMedsFound = globals.recentMeds
          .where((item) =>
              item.name.toLowerCase().contains(searchValue.toLowerCase()) ||
              item.pzn.toLowerCase().contains(searchValue.toLowerCase()))
          .toList();

      // Adds local search results on top.
      for (var i = 0; i < localMedsFound.length; i++) {
        plc.loadedItems.insert(0, localMedsFound[i]);
      }
    }
  }

  /// Retrieves the package leaflet [url] and adds it to the entered [item] object.
  /// Sends a GET-Request to [beipackzettel.de] with a search query based on the [pzn].
  /// Then parses the response to acquire the package leaflet [url].
  static Future<Med> getMedInfo(Med item) async {
    final resp = await http.get(
        'http://www.beipackzettel.de/search?utf8=%E2%9C%93&term=' + item.pzn);

    if (resp.statusCode == HttpStatus.ok) {
      String html = resp.body;

      String medName = Helper.parseMid(
          html, '<span class="hide-for-medium-down">', '</span>');
      if (medName.length > 0) {
        /// Also changing [item]'s name here, so it matches the one on the package leaflet.
        item.name = medName;
      }

      String medUrl = Helper.parseMid(
          html,
          '<td class="medium-3 large-3 column"><a class="button" href="',
          '">Beipackzettel anzeigen</a></td>');
      if (medUrl.length > 0) {
        /// Changing [item]'s package leaflet [url].
        item.url = 'http://www.beipackzettel.de/' + medUrl;
      }
    }

    return item;
  }

  /// Sends a GET-Request to the package leaflet [url], then parses the response.
  /// Removes some junk strings. Further processing is done in [med_info].
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
