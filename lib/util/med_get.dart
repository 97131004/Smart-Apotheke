import 'package:http/http.dart' as http;

import '../data/med.dart';
import 'helper.dart';

class MedGet {
  static Future<Med> getMed(Med item) async {
    final resp = await http.get(
        'http://www.beipackzettel.de/search?utf8=%E2%9C%93&term=' + item.pzn);
    //print(resp.body);

    String html = resp.body;

    String medName =
        Helper.parseMid(html, '<span class="hide-for-medium-down">', '</span>');
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

    return item;
  }

  static Future<String> getMedInfo(Med item) async {
    final resp = await http.get(item.url);

    String html =
        Helper.parseMid(resp.body, '<div class="content_area">', '<footer>');
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
    return null;
  }

  static Future<List<Med>> getMedSearch(
      String searchValue, int pageIndex, int pageCount) async {
    final resp = await http.get('https://www.docmorris.de/search?query="' +
        searchValue +
        '"&page=' +
        pageIndex.toString() +
        '&resultsPerPage=' +
        pageCount.toString());
    //print(resp.body);

    String html = resp.body;

    List<String> pzns =
        Helper.parseMid(html, 'exactag.product_id = \'', '\';').split(',');

    int searchIndex = 0;
    int index = 0;

    List<Med> list = new List<Med>();
    if (index == pzns.length - 1) return list;

    while (true) {
      searchIndex = html.indexOf('<span class="link name">', searchIndex + 1);
      if (searchIndex == -1) break;

      String medName = Helper.parseMid(
          html, '<span class="link name">', '</span>', searchIndex);

      //print(medName);

      if (index < pzns.length) {
        Med m = new Med(medName, pzns[index]);
        //print(pzns[index]);
        await MedGet.getMed(m);
        list.add(m);
        index++;
      }
    }

    return list;
  }
}
