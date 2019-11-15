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
  bool getSearchDone = false;
  static int pageCount = 5;
  static String searchValue = '';
  String lastSearchValue = '';

  @override
  void initState() {
    super.initState();
  }

  static PagewiseLoadController plvController = PagewiseLoadController(
    pageFuture: (pageIndex) {
      MedGet.getMedSearchPrefix(plvController, pageIndex, searchValue);
      return MedGet.getMedSearch(searchValue, pageIndex, pageCount);
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
                    onSubmitted: search,
                    decoration: new InputDecoration(
                      hintText: 'Medikament / PZN',
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                    ))),
            SizedBox(height: 10),
            //if (getSearchDone)
            Expanded(
              child: PagewiseListView(
                pageLoadController: plvController,
                showRetry: true,
                itemBuilder: (context, entry, index) {
                  return MedList.buildItem(context, entry, index);
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
      plvController.reset();
    }
  }
}
