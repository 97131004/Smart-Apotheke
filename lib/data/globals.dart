library maph_group3.globals;

import 'package:maph_group3/util/shop_items.dart';

import 'med.dart';

//List<Med> meds = new List<Med>();

List<Med> meds = [
  Med(
      'Ibu ratio 400 akut Schmerztabletten Filmtabletten (lokal)',
      '10019621',
      'http://www.beipackzettel.de/medikament/Ibu%2520ratio%2520400%2520akut%2520Schmerztablletten%2520Filmtabletten/A77827',
      true),
  Med(
      'Ibuprofen ratio 400 akut Schmerztabletten Filmtabletten (lokal)',
      '10019621',
      'http://www.beipackzettel.de/medikament/Ibu%2520ratio%2520400%2520akut%2520Schmerztablletten%2520Filmtabletten/A77827',
      true),
  Med(
      'Simvastatin - CT 40mg (lokal)',
      '4144658',
      'http://www.beipackzettel.de/medikament/Simvastatin%2520-%2520CT%252040mg%2520Filmtabletten/A88644',
      true),
];

Map<String, ShopItem> items = {
  '10019621': new ShopItem('Ibu ratio 400 akut Schmerztabletten Filmtabletten',
      '10019621', 'ratiopharm Gmbh', '20 Filmtabletten', '', 'assets/dummy_med.png', '3,39 €', '4,99 €',
      '0,17 €', 'MAPH_group3', 'Bei leichten bis mäßig starken Schmerzen wie Kopf-, Zahn-, '
          'Regelschmerzen und Fieber\nIbuprofen, der Wirkstoff von IBU ratiopharm 400 mg akut, '
          'ist ein bewährtes Mittel bei leichten bis mäßigen Kopfschmerzen, Fieber und anderen '
          'Alltagsschmerzen. Mit 400 mg des Wirkstoffes enthalten die Tabletten die höchste '
          'rezeptfreie Dosierung von Ibuprofen. Die Tabletten sollten immer mit einem Glas '
          'Wasser eingenommen werden.', 'ibuprofen', false), // Ibuprofen
  '4144658': new ShopItem('Simvastatin-CT 40mg', '4144658', 'AbZ-Pharma GmbH', '100 Stück, N3', '',
      'assets/dummy_med.png', '24,99 €', '', '0,24 €', 'MAPH_group3', '***Beschreibungstext***',
      'simvastin', true), // Simvastin
};