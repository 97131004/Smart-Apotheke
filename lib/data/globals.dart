library maph_group3.globals;

import 'package:maph_group3/util/shop_items.dart';
import 'med.dart';

/// Globally accessible storage file.

/// List of recently scanned or ordered medicaments (also includes some predefined
/// dummy medicaments). This list should be later outsourced to a database.
List<Med> recentMeds = [
  Med(
      'Ibu Lysin ratiopharm 684mg Filmtabletten',
      '10019638',
      'http://www.beipackzettel.de/medikament/Ibu%2520Lysin%2520ratiopharm%2520684mg%2520Filmtabletten/AB4204',
      true),
  Med(
      'Eliquis 5mg Filmtabletten',
      '01647809',
      'http://www.beipackzettel.de/medikament/Eliquis%25205mg%2520Filmtabletten/AC7815',
      true),
  Med(
      'Simvastatin - CT 40mg',
      '04144658',
      'http://www.beipackzettel.de/medikament/Simvastatin%2520-%2520CT%252040mg%2520Filmtabletten/A88644',
      true),
];

// Uncomment the next line to remove predefined recent medicaments.
// List<Med> meds = new List<Med>();

/// List of shopping informations and descriptions about medicaments, that can be
/// 'bought' from within the app using the iban and address entered by the user.
/// This list should be later outsourced to a database.
Map<String, ShopItem> shopMeds = {
  '10019638': new ShopItem(
      'Ibu Lysin ratiopharm 684mg Filmtabletten',
      '10019638',
      'ratiopharm Gmbh',
      '20 Filmtabletten',
      '',
      'assets/dummy_med.png',
      '3,39 €',
      '4,99 €',
      '0,17 €',
      'MAPH_group3',
      'Bei leichten bis mäßig starken Schmerzen wie Kopf-, Zahn-, '
          'Regelschmerzen und Fieber. Ibuprofen, der Wirkstoff von IBU ratiopharm 400 mg akut, '
          'ist ein bewährtes Mittel bei leichten bis mäßigen Kopfschmerzen, Fieber und anderen '
          'Alltagsschmerzen. Mit 400 mg des Wirkstoffes enthalten die Tabletten die höchste '
          'rezeptfreie Dosierung von Ibuprofen. Die Tabletten sollten immer mit einem Glas '
          'Wasser eingenommen werden.',
      'ibuprofen',
      false), // Ibuprofen
  '01647809': new ShopItem(
      'Eliquis 5mg Filmtabletten',
      '01647809',
      'Bristol-Myers Squibb',
      '200 Stück, N3',
      '',
      'assets/dummy_med.png',
      '9,99 €',
      '15,99',
      '0,09 €',
      'MAPH_group3',
      'Eliquis 5 mg Filmtabletten von '
          'Vertriebsgemeinschaft Bristol-Myers Squibb ist ein Arzneimittel. Filmtabletten sind mit einer '
          'dünnen Film-Schicht überzogen und erleichtern das Schlucken. Sie erhalten Eliquis 5 mg '
          'Filmtabletten in den Packungsgrößen zu 60 Stück, 200 Stück und 20 Stück.In der Packungsbeilage '
          'finden Sie umfängliche Informationen zum Produkt. Gerne beraten wir Sie auch persönlich. Dieses '
          'Arzneimittel ist nur mit Rezept erhältlich. Bitte senden Sie uns zur Bestellung Ihr '
          'Originalrezept per Post zu. Wie Sie das machen erfahren Sie unter Rezept einsenden. '
          'Übrigens: Für jedes rezeptpflichtige Medikament erhalten Sie einen Bonus.',
      'eliquis',
      true), // Eliquis
  '04144658': new ShopItem(
      'Simvastatin - CT 40mg',
      '04144658',
      'AbZ-Pharma GmbH',
      '100 Stück (N3)',
      '',
      'assets/dummy_med.png',
      '5,99 €',
      '7,99',
      '0,05 €',
      'MAPH_group3',
      'Eliquis 5 mg Filmtabletten von '
          'Das Arzneimittel enthält den Wirkstoff Simvastatin. Simvastatin ist ein Arzneimittel zur Senkung '
          'erhöhter Gesamt-Cholesterinwerte, von „schlechtem" LDL-Cholesterin und weiteren Fetten, den '
          'sogenannten Triglyzeriden, im Blut. Außerdem erhöht es die Werte von „gutem" HDL-Cholesterin. '
          'Das Präparat gehört zu der Klasse der als „Statine" bezeichneten Arzneimittel.',
      'simvastin',
      true), // Simvastin
  '01088942': new ShopItem(
      'Vertigoheel',
      '01088942',
      'Biologische Heilmittel Heel GmbH',
      '30ml (N1)',
      '',
      'assets/dummy_med.png',
      '13,99 €',
      '15,99 €',
      '0,10 €',
      'MAPH_group3',
      'Natürliche Arzneimittel wie '
          'Vertigoheel können helfen, Schwindelbeschwerden zu verbessern. Vertigoheel ist das meistverwendete '
          'Arzneimittel gegen Schwindelbeschwerden in Deutschland. Es enthält 4 Inhaltsstoffe (zum Beispiel '
          'Anamirta cocculus oder Conium maculatum), die sich gegenseitig in ihrer Wirkung ergänzen. Die '
          'Wirksamkeit wurde in Studien nachgewiesen. Dabei macht Vertigoheel nicht müde, die volle '
          'Konzentrationsfähigkeit bleibt erhalten. Da keine Neben- oder Wechselwirkungen bekannt sind, '
          'ist auch eine längerfristige Anwendung möglich.',
      'vertigoheel',
      false), // Vertigoheel
  '10108112': new ShopItem(
      'Omeprazol 20mg',
      '10108112',
      '1A Pharma GmbH',
      '100 Stück, N3',
      '',
      'assets/dummy_med.png',
      '19,50 €',
      '',
      '0,19 €',
      'MAPH_group3',
      'Keine Beschreibung verfügbar.',
      'omeprazol',
      true), // Omeprazol
};
