import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';

import '../util/no_internet_alert.dart';
import '../util/helper.dart';
import '../util/med_get.dart';
import '../util/med_list.dart';

class MedSearch extends StatefulWidget {
  MedSearch({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MedSearchState();
  }
}

class _MedSearchState extends State<MedSearch> {
  static bool getSearchDone = false;
  static int pageCount = 8;
  static String searchValue = '';
  String lastSearchValue = '';

  @override
  void initState() {
    Helper.hasInternet().then((internet) {
      if (internet == null || !internet) {
        NoInternetAlert.show(context);
      }
    });

    super.initState();

    getSearchDone = false;
    searchValue = '';
  }

  static PagewiseLoadController plc = PagewiseLoadController(
    pageFuture: (pageIndex) {
      if (searchValue.length > 0) {
        getSearchDone = true;
        MedGet.getMedsPrefix(plc, pageIndex, searchValue);
        return MedGet.getMeds(searchValue, pageIndex, pageCount);
      }
      return null;
    },
    pageSize: pageCount,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Medikament suchen'),
          backgroundColor: Colors.green,
        ),
        body: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                    autofocus: true,
                    onSubmitted: search,
                    decoration: new InputDecoration(
                     focusedBorder: InputBorder.none,
                      hintText: 'Name / PZN',
                      prefixIcon: const Icon(
                        
                        Icons.search,
                        color: Colors.green
                      ),
                    ))),
            SizedBox(height: 10),
            //if (getSearchDone)
            Expanded(
              child: PagewiseListView(
                pageLoadController: plc,
                showRetry: true,
                itemBuilder: (context, entry, index) {
                  if (getSearchDone) {
                    return MedList.buildItem(context, entry);
                  }
                  return null;
                },
                noItemsFoundBuilder: (context) {
                  return (searchValue.length > 0)
                      ? Text('Keine Medikamente gefunden.')
                      : null;
                },
                loadingBuilder: (context) {
                  return (searchValue.length > 0)
                      ? CircularProgressIndicator()
                      : null;
                },
                retryBuilder: (context, callback) {
                  return Column(
                    children: <Widget>[
                      Text(
                        'Fehler beim Suchen.\n' +
                            'Prüfen Sie Ihre Internetverbindung.\n' +
                            'Bitte gehen Sie zurück und versuchen es erneut.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ));
  }

  void search(String value) {
    if (value != lastSearchValue && value.length > 0) {
      searchValue = value;
      lastSearchValue = value;
      plc.reset();
    }
  }
}
