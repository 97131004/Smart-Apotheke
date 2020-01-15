import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maph_group3/util/helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/globals.dart';
import '../util/nampr.dart';
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

  CalendarController _controller = CalendarController();
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  List<int> selectedTimes;
  String _eventController;
  SharedPreferences prefs;
  String selectedMed;

  // variables are in the calendar form
  TextEditingController day_duration = new TextEditingController();

  // TextEditingController name_medical = new TextEditingController();
  TextEditingController dosage = new TextEditingController();
  TextEditingController note = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
    initPrefs();
    selectedTimes = [];
    _eventController = "";
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

  void removeNotification (int year, int month, int day, int event_index, String list_hours) async {
    String string_list_time = await Helper.readDataFromsp(list_hours);
    for (int i = 0; i < jsonDecode(string_list_time).length; i++) {
      int id = generator_id_notification(
          year, month, day, event_index, jsonDecode(string_list_time)[i]);
      //print(id);
      await flutterLocalNotificationsPlugin.cancel(id);
    }
  }

  void removeAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  int generator_id_notification(int year, int month, int day, int event_index,
      int hour) {
    int id = int.parse(month.toString() +
        day.toString() +
        event_index.toString() +
        hour.toString());
    return id;
  }

  Future<Null> save_clock_with_index_event(int year, int month, int day,
      int event_index, List time) async {
    int id = int.parse(year.toString() +
        month.toString() +
        day.toString() +
        event_index.toString());
    await prefs.setString(id.toString(), jsonEncode(time));
  }

  Future<void> scheduleNotification(DateTime dateTime, int event_index,
      List time, String text) async {
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
                  selectedColor: Theme
                      .of(context)
                      .primaryColor,
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
                selectedDayBuilder: (context, date, events) =>
                    Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                todayDayBuilder: (context, date, events) =>
                    Container(
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
                  (event) =>
                  Container(
                    height: 72,
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
                              String string_remove = _selectedEvents[index];
                              myFunction(_events, string_remove);
                              // Then show a snackbar.
                              Scaffold.of(context).showSnackBar(
                                  SnackBar(content: Text("$item dismissed")));
                            },
                            // Show a red background as the item is swiped away.
                            background: Container(color: Colors.red),
                            child: ListTile(
                                title: Text('$item')),
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

  Future<void> myFunction(myMap, String string_remove) async {
    for (var entry in myMap.entries) {
      print(entry.key);//not remove that is very important VAN TINH
      await _removeAsyncFunction(entry.key, entry.value, string_remove);
    }
  }

  _removeAsyncFunction(DateTime key , List list_value, String string_remove){
    if(list_value.length > 0){
                                  if(list_value.indexOf(string_remove) != -1){
                                    _selectedEvents = list_value;
                                    //print(list_value);
                                    _controller.setSelectedDay(key);//key is datetime
                                    int year = _controller.selectedDay.year;
                                    int month = _controller.selectedDay.month;
                                    int day = _controller.selectedDay.day;
                                    String day_event_index_inner = (int.parse(year.toString() + month.toString() + day.toString() + list_value.indexOf(string_remove).toString())).toString();

                                    removeNotification(year, month, day, list_value.indexOf(string_remove), day_event_index_inner);
                                    _selectedEvents.removeAt(list_value.indexOf(string_remove));//remove with value of item in list
                                  }
                                }
    setState(() {
      prefs.setString("events", json.encode(encodeMap(_events)));//setup again events
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last,
      CalendarFormat format) {
    //print('CALLBACK: _onVisibleDaysChanged');
  }

  void _showMultiSelect(BuildContext context) async {
    final List<MultiSelectDialogItem<int>> items = [];

    for (int i = 0; i < 24; i++) {
      items.add(MultiSelectDialogItem(i, i.toString() + ' Uhr'));
    }

    final result = await Navigator.push(
        context,
        NoAnimationMaterialPageRoute<Set<int>>(
            builder: (context) =>
                MultiSelectDialog(
                  items: items,
                  initialSelectedValues: selectedTimes.toSet(),
                )));

    setState(() {
      if (result != null) {
        if (result.length > 0) {
          selectedTimes = result.toList();
          selectedTimes.sort();
        }
        else {
          selectedTimes = [];
        }
      } else {
        selectedTimes = [];
      }
    });
  }

  _showTimes() {
    List<Widget> timesWidget = [];
    for (var item in selectedTimes) {
      timesWidget.add(Text(item.toString() + ' Uhr'));
    }
    return timesWidget;
  }

  _onAddButtonClick() {}
  var beginDate;

  _showAddDialog() {
    beginDate = _controller.selectedDay;
    bool isdatepicker = false;
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                  items: meds.map<DropdownMenuItem<String>>((
                                      Med med) {
                                    return DropdownMenuItem<String>(
                                      value: med.name,
                                      child: Text(med.name),
                                    );
                                  }).toList()),
                              SizedBox(height: 20),
                              InkWell(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
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
                                onTap: () =>
                                {
                                  setState(() {
                                    isdatepicker = !isdatepicker;
                                  })
                                },
                              ),
                              isdatepicker
                                  ? DatePickerTimeline(
                                beginDate,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 2,
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
                                InputDecoration(
                                    labelText: 'Einnahmedauer* (in Tagen)'),
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
                                decoration: InputDecoration(
                                    labelText: 'Dosierung * (Einnahmen/Tag)'),
                                controller: dosage,
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Notizen'),
                                controller: note,
                              ),
                              SizedBox(height: 20),
                              InkWell(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
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
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();

                                    _eventController = selectedMed +
                                        "\nDosierung: " +
                                        dosage.text +
                                        "\nNote: " +
                                        note.text;
                                    setState(() {
                                      for (int i = 0; i <= int.parse(day_duration.text); i++) {
                                        DateTime nextDay =
                                        beginDate.add(new Duration(days: i));
                                        if (_events[nextDay] != null) {
                                          _events[nextDay].add(
                                              _eventController);
                                        } else {
                                          _events[nextDay] = [_eventController];
                                        }
                                        prefs.setString(
                                            'events',
                                            json.encode(encodeMap(_events)));
                                        if (selectedTimes.length > 0) {
                                          scheduleNotification(
                                              nextDay,
                                              _events[nextDay]
                                                  .indexOf(_eventController),
                                              selectedTimes,
                                              _eventController.toString());
                                        }
                                        _controller.setSelectedDay(beginDate);
                                      }
                                    });
                                  }
                                  _eventController = '';
                                  dosage.text = '';
                                  day_duration.text = '';
                                  note.text = '';

                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          )));
                }))).then((_) => setState(() {}));
  }
}