import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';

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
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Medikament suchen'),
        ),
        body: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                    autofocus: true,
                    onSubmitted: search,
                    decoration: new InputDecoration(
                      hintText: 'Name / PZN',
                      prefixIcon: const Icon(
                        Icons.search,
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
                      ? Text('No Items Found')
                      : null;
                },
                loadingBuilder: (context) {
                  return (searchValue.length > 0)
                      ? CircularProgressIndicator()
                      : null;
                },
                /*
                retryBuilder: (context, callback) {
                  return RaisedButton(
                      child: Text('Retry'), onPressed: () => callback());
                },
                errorBuilder: (context, error) {
                  return Text('Error: $error');
                },
                */
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
