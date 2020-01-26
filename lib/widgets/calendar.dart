import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maph_group3/util/helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as math2;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/globals.dart';
import '../util/nampr.dart';
import '../util/calendar_multi_select_dialog.dart';
import 'package:maph_group3/data/globals.dart';
import 'package:maph_group3/data/med.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

/// Page to show a Table Calendar. Here you can add the event for multiple day
/// When you click button + on the right bottom you got a form.
/// The first field is a dropdow and a small text field, you can select existed Medical or wirte another Meidical.
/// The second field is selectedDay,you can change the beginday here,if you click on the day.
/// The next is for days, That means howlong will you be using the MEDICAL for yourself.
/// The text Dosierung = Dosage means that how should you use the medical.
/// Notizen is clearly, you can note somethings here.
/// Urzeiten: Heer you can select a Notification like medication reminders.
/// Each Notification has a ID to control and has been working on just only hour.
/// That works every day until you remove it.
///
/// important referencens:
/// https://pub.dev/packages/table_calendar
/// https://pub.dev/packages/flutter_local_notifications
class Calendar extends StatefulWidget {
  Calendar({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  /// global variable for LocalNotificationPlugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// global Calendar to show calendar
  CalendarController _controller = CalendarController();

  /// Map: Storing all Events in the Calendar
  Map<DateTime, List<dynamic>> _events;

  /// global: Storing a selected Event, when you click on the table
  List<dynamic> _selectedEvents;

  /// For temporal String is combinated from the name of medical,dosage and note
  String _stringCombination;

  /// The variable for the saving data in local phone or tablet
  SharedPreferences _sharedPrefs;

  /// variables are in the calendar form
  TextEditingController _day_duration = new TextEditingController();
  TextEditingController _dosage = new TextEditingController();
  TextEditingController _note = new TextEditingController();

  ///  Storing Time for Notification
  List<int> _selectedTimes;

  /// variable to set selected Begin Day with your wish in the form
  var _beginDate;

  /// variable to be using amimation for table calendar and the form
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _events = {};
    _readRecentMed();
    _initSharedPreferences();
    _selectedEvents = [];
    _selectedTimes = [9, 17];
    _stringCombination = "";
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    initializeNotifications();
    // Initialaziton for the Animation with 0 seconds or you can change more time and with [SingleTickerProviderStateMixin]
    _animationController =
    AnimationController(duration: Duration(seconds: 0), vsync: this)
      ..forward();
  }


  /// Read data [recentMed], what you scanned or ordered (by button [bestellen]) from history to calendar form
  void _readRecentMed() async {
    await Helper.recentMedsLoad();
  }

  /// Initialization a Notification for Android and IOS
  initializeNotifications() async {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);
  }

  /// Initialization a [SharedPreferences] and read data [events], which saved with the string name [events]
  _initSharedPreferences() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          _decodeMap(json.decode(_sharedPrefs.getString("events") ?? "{}")));
    });
  }

  /// Encoding Map<DateTime,Dynamic> Convert DateTime Key in the Map to string
  /// in oder to save events like a string
  Map<String, dynamic> _encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  /// Decoding [Map] when you read Map from [SharedPreferences]
  /// and you have to convert DateTime from String to DateTime, which you changed before
  Map<DateTime, dynamic> _decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  /// returning page when you click a appeared notificaton on the screen
  Future _onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => Calendar()),
    );
  }

  /// Removing a event and concurent Notification with a ID
  /// ID consisted of month, day, index event, hour
  void _removeNotification(
      int year, int month, int day, int eventIndex) async {
    String _stringListTime = year.toString() + month.toString() + day.toString() + eventIndex.toString();
    String stringListTime = await Helper.readDataFromsp(_stringListTime);

    if(jsonDecode(stringListTime).length > 0){
      for (int i = 0; i < jsonDecode(stringListTime).length; i++) {
        int id = _generateIDNotification(year, month, day, eventIndex, jsonDecode(stringListTime)[i]);
        //print(id);
        await flutterLocalNotificationsPlugin.cancel(id);
      }
    }
  }

  /// Creating a ID for Notification consisted of month, day, index of event, hour
  /// the formular will return a unique int. because we have just 12 month
  /// year is diffezent I was remove because the nummer is so big out of int: 2^-31 to 2^31-1
  int _generateIDNotification(
      int year, int month, int day, int eventIndex, int hour) {
    int id = year * 12 * 30 * 24 + month * 30 * 24 + day * 24 + eventIndex + hour;
    return id;
  }

  /// Saving Hours in the Local, in order to remove Notification, which Event you saved before with uhrzeit
  Future<Null> _saveClockWithYearMonthDayIndexEvent(
      int year, int month, int day, int eventIndex, List time) async {
    String _stringListime = year.toString() + month.toString() + day.toString() + eventIndex.toString();
    await _sharedPrefs.setString(_stringListime, jsonEncode(time));
  }

  /// show Nofitication at the time [hour]
  Future<void> _showDailyAtTime (
      DateTime dateTime, int eventIndex, List time, String text) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      'repeatDailyAtTime description',
      importance: Importance.Max,
      sound: 'sound',
      ledColor: Color(0xFF3EB16F),
      ledOffMs: 1000,
      ledOnMs: 1000,
      enableLights: true,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;
    //print(dateTime);
    // save list time with String = year.tostring() + month.toString() + day.toString() + eventIndex.toString()
    _saveClockWithYearMonthDayIndexEvent(year, month, day, eventIndex, time);

    //show everday
//    if (time.length > 0) {
//      for (int i = 0; i < time.length; i++) {
//        int hour = time[i];
//        int id = _generateIDNotification(year, month, day, eventIndex, hour);
//        await flutterLocalNotificationsPlugin.showDailyAtTime(
//            id,
//            'Medikament : $text',
//            'Zeit,Ihre Medikamente gemäß Zeitplan einzunehmen',
//            Time(hour, 0, 0),
//            platformChannelSpecifics);
//      }
//    }
    //show with day you want if you want  this is just one option for you
//    static const Sunday = Day(1);
//    static const Monday = Day(2);
//    static const Tuesday = Day(3);
//    static const Wednesday = Day(4);
//    static const Thursday = Day(5);
//    static const Friday = Day(6);
//    static const Saturday = Day(7);
//    if (time.length > 0) {
//      for (int i = 0; i < time.length; i++) {
//        int hour = time[i];
//        int id = _generateIDNotification(year, month, day, eventIndex, hour);
//        await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
//            id,
//            'Medikament : $text',
//            'Zeit,Ihre Medikamente gemäß Zeitplan einzunehmen',
//            Day(1),
//            Time(hour, 0, 0),
//            platformChannelSpecifics);
//      }
//    }
      //show notification on time and day you want
    if (time.length > 0) {
      for (int i = 0; i < time.length; i++) {
        int hour = time[i];
        int id = _generateIDNotification(year, month, day, eventIndex, hour);
        //print(id);
        await flutterLocalNotificationsPlugin.schedule(
            id,
            'Medikament : $text',
            'Zeit,Ihre Medikamente gemäß Zeitplan einzunehmen',
            DateTime(year, month, day, hour.toInt(), 0, 0),
            platformChannelSpecifics);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Heute',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () {
              setState(() {
                _controller.setFocusedDay(DateTime.now());
                _controller.setSelectedDay(DateTime.now(), runCallback: true);
              });
            },
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TableCalendar(
                //locale: 'de_DE',
                events: _events,
                initialCalendarFormat: CalendarFormat.month,
                calendarStyle: CalendarStyle(
                    canEventMarkersOverflow: true,
                    todayColor: Colors.teal,
                    selectedColor: Theme.of(context).primaryColor,
                    todayStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white)),
                headerStyle: HeaderStyle(
                  centerHeaderTitle: true,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                  formatButtonShowsNext: false,
                ),
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: (date, events) {
                  setState(() {
                    _selectedEvents = events;
                  });
                },
                onVisibleDaysChanged: _onVisibleDaysChanged,
                builders: CalendarBuilders(
                  selectedDayBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(25.0)),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(color: Colors.white),
                      )),
                  todayDayBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(25.0)),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                calendarController: _controller,
              ),
              ..._selectedEvents.map(
                (event) => Container(
                  height: 85,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.8),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          // Each Dismissible must contain a Key. Keys allow Flutter to
                          // uniquely identify widgets.
                          key: UniqueKey(),
                          // Provide a function that tells the app
                          // what to do after an item has been swiped away.
                          onDismissed: (direction) async {
                            // Remove the clock for each event in a day by shared SharedPreferences to get clock .
                            String stringRemove = _selectedEvents[index];
                            _readMapDateTimeList(_events, stringRemove);
                            // Then show a snackbar.
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text("$event dismissed")));
                          },
                          // Show a red background as the item is swiped away.
                          background: Container(color: Colors.red),
                          child: ListTile(title: Text('$event')),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
        builder: (context, child) => Transform.rotate(
            child: child,
            origin: Offset(50, 50),
            angle: _animationController.value * 2.0 * math.pi),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: _showAddDialog
      ),
    );
  }

  /// Read Map[_events] with for instead foreach,because  you can read with async easier
  Future<void> _readMapDateTimeList(myMap, String stringRemove) async {
    for (var entry in myMap.entries) {
      /// I can not remove this print , that is for async await reading map,
      /// If I do not show , I got just 2 elements of map
      print(entry.key); //not remove that is very important VAN TINH
      await _removeAsyncEvent(entry.key, entry.value, stringRemove);
    }
  }

  /// remove Event while finding [stringRemove] and removeNotification
  /// you have to set [_controller.setSelectedDay(dateTime)] to remove corresponding notification
  _removeAsyncEvent(DateTime dateTime, List listValue, String stringRemove) {
    if (listValue.length > 0) {
      // indexOf return 1 if not found end inversely
      if (listValue.indexOf(stringRemove) != -1) {
        _selectedEvents = listValue;
        _controller.setSelectedDay(dateTime);
        int year = _controller.selectedDay.year;
        int month = _controller.selectedDay.month;
        int day = _controller.selectedDay.day;
        _removeNotification(year, month, day, listValue.indexOf(stringRemove));

        _selectedEvents.removeAt(listValue
            .indexOf(stringRemove)); //remove with value of item in list
      }
    }
    setState(() {
      _sharedPrefs.setString(
          "events", json.encode(_encodeMap(_events))); //setup again [events]
    });
  }

  // when visibled day was changed,like changed to other month
  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    //print('CALLBACK: _onVisibleDaysChanged');
  }

  /// Rendering Multiple Select from [calendar_multi_select_dialog]
  void _showMultiSelect(BuildContext context) async {
    final List<MultiSelectDialogItem<int>> items = [];

    for (int i = 0; i < 24; i++) {
      items.add(MultiSelectDialogItem(i, i.toString() + ' Uhr'));
    }

    final result = await Navigator.push(
        context,
        NoAnimationMaterialPageRoute<Set<int>>(
            builder: (context) => MultiSelectDialog(
              items: items,
              initialSelectedValues: _selectedTimes.toSet(),
            )));

    setState(() {
      if (result != null) {
        if (result.length > 0) {
          _selectedTimes = result.toList();
          _selectedTimes.sort();
        } else {
          _selectedTimes = [];
        }
      } else {
        _selectedTimes = [];
      }
    });
  }

  /// show Uhrzeit when you selected
  _showTimes() {
    List<Widget> timesWidget = [];
    for (var item in _selectedTimes) {
      timesWidget.add(Text(item.toString() + ' Uhr'));
    }
    return timesWidget;
  }

  /// GetMedList to Dropdown into field Medikament
  _getMedListForEventBox(List<Med> meds) {
    var medlist = meds.map<DropdownMenuItem<String>>((Med med) {
      return DropdownMenuItem<String>(
        value: med.name,
        child: Text(med.name),
      );
    }).toList();
    medlist.add(DropdownMenuItem<String>(
      value: 'Benutzereingabe...',
      child: Text('Benutzereingabe...'),
    ));
    return medlist;
  }

  // Handling when you clicked save on the form
  _handelButtonSave(String actualSelectMed, GlobalKey<FormState> _formKey) {
    if (_formKey.currentState.validate() && actualSelectMed != null) {
      _formKey.currentState.save();

      _stringCombination = "Medikament: " +
          actualSelectMed +
          "\nDosierung: " +
          _dosage.text +
          "\nNote: " +
          _note.text;
      setState(() {
        _controller.setSelectedDay(_beginDate, runCallback: true);

        for (int i = 0; i < int.parse(_day_duration.text); i++) {
          DateTime nextDay = _beginDate.add(new Duration(days: i));
          _controller.setFocusedDay(nextDay);
          _controller.setSelectedDay(nextDay, runCallback: true);
            if (_events[_controller.selectedDay] != null) {
              _events[_controller.selectedDay].add(_stringCombination);
            } else {
              _events[_controller.selectedDay] = [_stringCombination];
            }
        // add for multiple day
          if (_selectedTimes.length > 0) {
            _showDailyAtTime(
                  nextDay,
                _events[_controller.selectedDay].indexOf(_stringCombination),
                _selectedTimes,
                actualSelectMed.toString() != null?actualSelectMed.toString(): _stringCombination.toString());
          }

          _controller.setSelectedDay(_beginDate, runCallback: true);
        }
      });
      _sharedPrefs.setString('events', json.encode(_encodeMap(_events)));
      _controller.setSelectedDay(_beginDate, runCallback: true);
    }
    _stringCombination = '';
    _dosage.text = '';
    _day_duration.text = '';
    _note.text = '';
    Navigator.of(context).pop();
  }

  /// Showing Dialog with a [showGeneralDialog] and then a [Form] inside
  _showAddDialog()  {
    List<Med> medList = [];
    // add to list [medList]
    medList.addAll(recentMeds);
    // selected Medicin for the Dropdown
    String actualSelectMed;
    _beginDate = _controller.selectedDay;
    bool isdatepicker = false;

    /// local variable For validator the input in form
    final _formKey = GlobalKey<FormState>();
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {},
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.4),
        barrierLabel: '',
        transitionBuilder: (context, anim1, anim2, child) {
          return Transform.rotate(
              angle: math2.radians(anim1.value * 360),
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Text('Erinnerungen erstellen'),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                DropdownButton<String>(
                                    value: actualSelectMed,
                                    isExpanded: true,
                                    onChanged: (String value) {
                                      if (value == 'Benutzereingabe...') {
                                        TextEditingController usermed =
                                        TextEditingController();
                                        bool medAdded = false;
                                        showDialog(
                                          // barrierDismissible: false,
                                            builder: (context) =>
                                                AlertDialog(
                                                  title: Text(
                                                      'Schreiben Sie eine Medikament'),
                                                  content: Form(
                                                    child: Column(
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      children: <Widget>[
                                                        Row(
                                                          children: <
                                                              Widget>[
                                                            Flexible(
                                                                child:
                                                                TextFormField(
                                                                  decoration: InputDecoration(
                                                                      labelText:
                                                                      'Medikament *:'),
                                                                  controller:
                                                                  usermed,
                                                                )),
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.check,
                                                                size: 40,
                                                              ),
                                                              onPressed:
                                                                  () {
                                                                if (usermed
                                                                    .text ==
                                                                    "") {
                                                                  //do not come back
                                                                } else {
                                                                  setState(
                                                                          () {
                                                                        medList.add(Med(
                                                                            usermed.text,
                                                                            ''));
                                                                        medAdded =
                                                                        true;
                                                                      });
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              },
                                                            )
                                                          ],
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            context: context)
                                            .then((_) {
                                          setState(() {
                                            if (medAdded)
                                              actualSelectMed = usermed.text;
                                            else
                                              actualSelectMed = value;
                                          });
                                        });
                                      } else
                                        setState(() {
                                          actualSelectMed = value;
                                        });
                                    },
                                    hint: Text('Medikament'),
                                    items: _getMedListForEventBox(medList)),
                                SizedBox(height: 20),
                                InkWell(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'Beginn',
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                          _beginDate.day.toString() +
                                              '.' +
                                              _beginDate.month.toString() +
                                              '.' +
                                              _beginDate.year.toString(),
                                          textAlign: TextAlign.right),
                                    ],
                                  ),
                                  onTap: () => {
                                    setState(() {
                                      isdatepicker = !isdatepicker;
                                    })
                                  },
                                ),
                                isdatepicker
                                    ? DatePickerTimeline(
                                  _beginDate,
                                  width:
                                  MediaQuery.of(context).size.width /
                                      2,
                                  locale: 'de_DE',
                                  onDateChange: (date) {
                                    setState(() {
                                      _beginDate = date;
                                    });
                                  },
                                )
                                    : Container(),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Keine gültige Eingabe';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      labelText: 'Einnahmedauer (in Tagen)*'),
                                  keyboardType: TextInputType.number,
                                  controller: _day_duration,
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Keine gültige Eingabe';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      labelText: 'Dosierung pro Tag:*'),
                                  controller: _dosage,
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  decoration:
                                  InputDecoration(labelText: 'Notizen'),
                                  controller: _note,
                                ),
                                SizedBox(height: 20),
                                InkWell(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('Uhrzeiten: '),
                                      Column(children: _showTimes())
                                    ],
                                  ),
                                  onTap: () {
                                    _showMultiSelect(context);
                                  },
                                ),
                                SizedBox(height: 20),
                                RaisedButton(
                                  child: Text(
                                    "Hinzufügen",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    await _handelButtonSave(
                                        actualSelectMed, _formKey);
                                  },
                                ),
                              ],
                            )));
                  },
                ),
              ));
        },
        transitionDuration: Duration(milliseconds: 600))
        .then((_) => setState(() {}));
  }
}