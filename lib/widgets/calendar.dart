import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maph_group3/util/helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'MultiSelectDialogItem.dart';
import 'package:maph_group3/data/globals.dart';
import 'package:maph_group3/data/med.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

class Calendar extends StatefulWidget {
  Calendar({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  final _formKey = GlobalKey<FormState>(); //for validate input
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  List<int> selectedTimes ;
  TextEditingController _eventController;
  SharedPreferences prefs;

  // variables are in the calendar form
  TextEditingController day_duration = new TextEditingController();
  // TextEditingController name_medical = new TextEditingController();
  TextEditingController dosage = new TextEditingController();
  TextEditingController note = new TextEditingController();
  List _myclock; //for multiple select o' clock

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];
    initPrefs();

    day_duration = TextEditingController();
    // name_medical = TextEditingController();
    note = TextEditingController();
    dosage = TextEditingController();
    _myclock = [];

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    selectedTimes = [8,14,20];
  }

  initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString("events") ?? "{}")));
    });
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => Calendar()),
    );
  }

  void removeNotification(
      int year, int month, int day, int event_index, List list_hours) async {
   
    for (int i = 0; i < list_hours.length; i++) {
      int id = generator_id_notification(
          year, month, day, event_index, list_hours[i]);
      print(id);
      await flutterLocalNotificationsPlugin.cancel(id);
    }
  }

  void removeAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  int generator_id_notification(
      int year, int month, int day, int event_index, int hour) {
    int id = int.parse(month.toString() +
        day.toString() +
        event_index.toString() +
        hour.toString());
    return id;
  }

  Future<Null> save_clock_with_index_event(
      int year, int month, int day, int event_index, List time) async {
    int id = int.parse(year.toString() +
        month.toString() +
        day.toString() +
        event_index.toString());
    await prefs.setString(id.toString(), jsonEncode(time));
  }

  Future<void> scheduleNotification(
      DateTime dateTime, int event_index, List time, String text) async {
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

    save_clock_with_index_event(year, month, day, event_index, time);

    if (time.length > 0) {
      for (int i = 0; i < time.length; i++) {
        int hour = time[i];
        int id = generator_id_notification(year, month, day, event_index, hour);
        print(id);
        await flutterLocalNotificationsPlugin.showDailyAtTime(
            id,
            'Medikamente: $text',
            'Es ist an der Zeit, Ihre Medikamente gemäß Zeitplan einzunehmen',
            Time(hour, 0, 0),
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
      ),
      body: SingleChildScrollView(
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
                  ;
                });
              },
              onVisibleDaysChanged: _onVisibleDaysChanged,
              builders: CalendarBuilders(
                selectedDayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white),
                    )),
                todayDayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              calendarController: _controller,
            ),
            ..._selectedEvents.map(
              (event) => Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      final item = event;

                      return Dismissible(
                        // Each Dismissible must contain a Key. Keys allow Flutter to
                        // uniquely identify widgets.
                        key: Key(item),
                        // Provide a function that tells the app
                        // what to do after an item has been swiped away.
                        onDismissed: (direction) async {
                          // Remove the clock for each event in a day by shared SharedPreferences to get clock .
                          int year = _controller.selectedDay.year;
                          int month = _controller.selectedDay.month;
                          int day = _controller.selectedDay.day;
                          String event_index_inner = (int.parse(
                                  year.toString() +
                                      month.toString() +
                                      day.toString() +
                                      index.toString()))
                              .toString();
                          String events_calendar =
                              await Helper.readDataFromsp(event_index_inner);
                          removeNotification(year, month, day, index,
                              jsonDecode(events_calendar));
                          //setup again events
                          setState(() {
                            _selectedEvents.removeAt(index);
                            prefs.setString(
                                "events", json.encode(encodeMap(_events)));
                          });
                          // Then show a snackbar.
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text("$item dismissed")));
                        },
                        // Show a red background as the item is swiped away.
                        background: Container(color: Colors.red),
                        child: ListTile(title: Text('$item')),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }
  
  void _showMultiSelect(BuildContext context) async {
    final List<MultiSelectDialogItem> items = [];

    for(int i = 0; i <24; i ++ ){
      items.add(MultiSelectDialogItem(i, i.toString() + ' Uhr'));
    }
    final setResult = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
          initialSelectedValues: [9, 12, 18].toSet(),
        );
      },
    );

    setState(() {
      if (setResult.length > 0) {
        selectedTimes = setResult.toList();
      }
    });
  }

  String selectedMed;

  var beginDate;
  _showAddDialog() {
    beginDate = _controller.selectedDay;
    bool isdatepicker = false;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(content:
                StatefulBuilder(// You need this, notice the parameters below:

                    builder: (BuildContext context, StateSetter setState) {
              return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      DropdownButton<String>(
                          value: selectedMed,
                          isExpanded: true,
                          onChanged: (String value) {
                            setState(() {
                              selectedMed = value;
                            });
                          },
                          hint: Text('Medikament'),
                          items: meds.map<DropdownMenuItem<String>>((Med med) {
                            return DropdownMenuItem<String>(
                              value: med.name,
                              child: Text(med.name),
                            );
                          }).toList()),
                      SizedBox(height: 20),
                      InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Beginn',
                              textAlign: TextAlign.left,
                            ),
                            Text(
                                beginDate.day.toString() +
                                    '.' +
                                    beginDate.month.toString() +
                                    '.' +
                                    beginDate.year.toString(),
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
                              beginDate,
                              width: MediaQuery.of(context).size.width / 2,
                              locale: 'de_DE',
                              onDateChange: (date) {
                                setState(() {
                                  beginDate = date;
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
                        decoration:
                            InputDecoration(labelText: 'Einnahmedauer*'),
                        keyboardType: TextInputType.number,
                        controller: day_duration,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Keine gültige Eingabe';
                          }
                          return null;
                        },
                        decoration: InputDecoration(labelText: 'Dosierung *'),
                        controller: dosage,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Notizen'),
                        controller: note,
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        child: Text('Wählen Sie Uhrzeit'),
                        onTap: () {
                          _showMultiSelect(context);
                        },
                      ),
                      SizedBox(height: 20),
                      FlatButton(
                        color: Colors.teal,
                        child: Text(
                          "Hinzufügen",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();

                            if (note.text != null) {
                              _eventController.text = selectedMed +
                                  "-- " +
                                  dosage.text +
                                  "--" +
                                  note.text;
                            } else {
                              _eventController.text =
                                  selectedMed + "--" + dosage.text;
                            }
                            if (_eventController.text != null &&
                                _eventController.text != "") {
                              // DateTime time_anfang = _controller.selectedDay;

                              setState(() {
                                for (int i = 0;
                                    i <= int.parse(day_duration.text);
                                    i++) {
                                  DateTime nextDay =
                                      beginDate.add(new Duration(days: i));
                                  if (_events[nextDay] != null) {
                                    _events[nextDay].add(_eventController.text);
                                  } else {
                                    _events[nextDay] = [_eventController.text];
                                  }

                                  prefs.setString('events',
                                      json.encode(encodeMap(_events)));
                                  if (selectedTimes != null) {
                                    scheduleNotification(
                                        nextDay,
                                        _events[nextDay]
                                            .indexOf(_eventController.text),
                                        selectedTimes,
                                        _eventController.toString());
                                  }
                                }
                                _eventController.clear();
                                Navigator.pop(context);
                              });
                              //name_medical.clear();
                              dosage.clear();
                              note.clear();
                              day_duration.clear();
                            }
                          }
                        },
                      ),
                    ],
                  )));
            })));
  }
}
