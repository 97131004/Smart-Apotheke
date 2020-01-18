import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import '../util/no_internet_alert.dart';
import '../util/helper.dart';
import '../util/med_get.dart';
import '../util/med_list.dart';

/// Page to search for a medicament [name] or [pzn] defined by the user. Search results
/// are coming from a GET-Request to [docmorris.de], then parsed and displayed here.
/// First loads a fixed number of results, then loads the next set of results
/// when user scrolls further down.
class MedSearch extends StatefulWidget {
  MedSearch({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MedSearchState();
  }
}

class _MedSearchState extends State<MedSearch> {
  /// [true] when [_plc] finished loading first search results.
  static bool _getSearchDone = false;
  static final int _resultsPerPage = 8;
  static String _searchValue = '';
  String _lastSearchValue = '';

  @override
  void initState() {
    /// Checks for internet connection. If there's no connection, a
    /// [no_internet_alert] will be shown.
    Helper.hasInternet().then((internet) {
      if (internet == null || !internet) {
        NoInternetAlert.show(context);
      }
    });

    super.initState();

    /// Since it's required to create a static [PagewiseLoadController], we have to reset
    /// the other static variables, that might have been changed in previous searchings.
    _getSearchDone = false;
    _searchValue = '';
  }

  /// Controls the page-wise output of the search results. [pageFuture] is called
  /// (also increases [pageIndex] by 1) when user's scrollview reaches the bottom
  /// of the widget. Then, another GET-Request is done to fetch the search
  /// results from the next page.
  static PagewiseLoadController _plc = PagewiseLoadController(
    pageFuture: (pageIndex) async {
      if (_searchValue.length > 0) {
        _getSearchDone = true;

        /// Adding local search results on top from the [globals.meds] list.
        MedGet.getMedsPrefix(_plc, pageIndex, _searchValue);

        /// Adding search results from the web.
        return await MedGet.getMeds(
            _searchValue, pageIndex, _resultsPerPage, true);
      }
      return null;
    },
    pageSize: _resultsPerPage,
  );

  /// Shows a list of search results and corresponding loading bars.
  /// Shows a note on no search results found.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Medikament suchen'),
        ),
        body: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                    autofocus: true,
                    onSubmitted: _search,
                    decoration: new InputDecoration(
                      hintText: 'Name / PZN',
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                    ))),
            SizedBox(height: 10),
            Expanded(
              child: Scrollbar(
                child: PagewiseListView(
                  pageLoadController: _plc,
                  showRetry: true,
                  itemBuilder: (context, entry, index) {
                    if (_getSearchDone) {
                      return MedList.buildItem(context, index, entry);
                    }
                    return null;
                  },
                  noItemsFoundBuilder: (context) {
                    return (_searchValue.length > 0)
                        ? Text('Keine Medikamente gefunden.')
                        : null;
                  },
                  loadingBuilder: (context) {
                    return (_searchValue.length > 0)
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
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }

  /// Starts a new medicament search if search value differs
  /// from last one and is not empty.
  void _search(String value) {
    if (value != _lastSearchValue && value.length > 0) {
      _searchValue = value;
      _lastSearchValue = value;
      _plc.reset();
    }
  }
}
