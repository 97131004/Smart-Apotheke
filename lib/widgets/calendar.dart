import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maph_group3/util/helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:maph_group3/util/calendar_data.dart';
import 'dart:math';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calendar extends StatefulWidget {
  Calendar({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  final _formKey = GlobalKey<FormState>(); //for validate input
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  TextEditingController _eventController;
  SharedPreferences prefs;

  // variables are in the calendar form
  TextEditingController day_duration = new TextEditingController();
  TextEditingController name_medical = new TextEditingController();
  TextEditingController dosage = new TextEditingController();
  TextEditingController note = new TextEditingController();
  List _myclock;//for multiple select o' clock

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];
    initPrefs();

    day_duration = TextEditingController();
    name_medical = TextEditingController();
    note = TextEditingController();
    dosage = TextEditingController();
    _myclock = [];

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => Calendar()),
    );
  }

  void removeNotification(List list) async {
    for(int i = 0; i < list.length ; i++){
     //nt id = generator_id_notification (int year, int month, int day, int event_index, int hour)
      await flutterLocalNotificationsPlugin.cancel(i);
    }
  }

  void removeAllNotification() async {
     await flutterLocalNotificationsPlugin.cancelAll();
  }

  int generator_id_notification (int year, int month, int day, int event_index, int hour){
    int id = int.parse(year.toString() + month.toString() + day.toString() + event_index.toString() + hour.toString());
    return id;
  }

  Future<Null> save_clock_with_index_event(int year, int month, int day, int event_index, List time) async{
    int id = int.parse(year.toString() + month.toString() + day.toString() + event_index.toString());
    await prefs.setString(id.toString(), jsonEncode(time));
  }

  Future<void> scheduleNotification(DateTime dateTime, int event_index, List time, String text) async {
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

    save_clock_with_index_event(year,month,day,event_index,time);

    if(time.length > 0){
      for (int i = 0; i < time.length ; i++){
        int hour = time[i];
        int id = generator_id_notification(year, month, day, event_index, hour);
        //print(id);
        await flutterLocalNotificationsPlugin.showDailyAtTime(
            id,
            'Mediminder: $text',
            'It is time to take your medicine, according to schedule',
            Time(hour, 0, 0),
            platformChannelSpecifics);
      }
    }
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString("events") ?? "{}")));
    });
  }

  @override
  void dispose() {
    super.dispose();
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
              events: _events,
              initialCalendarFormat: CalendarFormat.week,
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
                  _selectedEvents = events;;
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
                        onDismissed: (direction) async{
                          // Remove the clock for each event in a day by shared SharedPreferences to get clock .
                          int year = _controller.selectedDay.year;
                          int month = _controller.selectedDay.month;
                          int day = _controller.selectedDay.day;
                          String event_index_inner = (int.parse(year.toString() + month.toString() + day.toString() + index.toString())).toString();
                          String events_calendar = await Helper.readDataFromsp(event_index_inner);
                          removeNotification(jsonDecode(events_calendar));
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

  _showAddDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration:
                      InputDecoration(labelText: 'Tagesdauer vom ausgewählten Tag *'),
                      keyboardType: TextInputType.number,
                      controller: day_duration,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration:
                          InputDecoration(labelText: 'Medikament Name *'),
                      controller: name_medical,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Dosage *'),
                      controller: dosage,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Note'),
                      controller: note,
                    ),
                    Container(
                      margin: new EdgeInsets.only(
                          left: 0, top: 15.0, right: 0, bottom: 15.0),
                      child: MultiSelect(
                          autovalidate: false,
                          titleText: "Wählen Sie die Datum",
                          validator: (value) {
                            if (value == null) {
                              return 'Please select one or more option(s)';
                            }
                          },
                          errorText: 'Please select one or more option(s)',
                          dataSource: [
                            {
                              "display": "9 Uhr",
                              "value": 9,
                            },
                            {
                              "display": "12 Uhr",
                              "value": 12,
                            },
                            {
                              "display": "18 Uhr",
                              "value": 18,
                            },
                            {
                              "display": "21 Uhr",
                              "value": 21,
                            }
                          ],
                          textField: 'display',
                          valueField: 'value',
                          filterable: true,
                          required: true,
                          value: _myclock,
                          onSaved: (value) {
                              setState(() {
                                _myclock = value;
                              });
                          }),
                    ),
                    Container(
                        margin: new EdgeInsets.symmetric(horizontal: 80.0),
                        child: FlatButton(
                          color: Colors.teal,
                          child: Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();

                              if (note.text != null) {
                                _eventController.text = name_medical.text +
                                    "-- " +
                                    dosage.text +
                                    "--" +
                                    note.text;
                              } else {
                                _eventController.text =
                                    name_medical.text + "--" + dosage.text;
                              }
                              if (_eventController.text != null &&
                                  _eventController.text != "") {
                                DateTime time_anfang = _controller.selectedDay;

                                setState(() {
                                  for (int i = 0; i <= int.parse(day_duration.text); i++){
                                    DateTime time = _controller.selectedDay.add(new Duration(days: i));
                                    _controller.setSelectedDay(time);

                                    if (_events[_controller.selectedDay] !=
                                        null) {
                                      _events[_controller.selectedDay]
                                          .add(_eventController.text);
                                    } else {
                                      _events[_controller.selectedDay] = [
                                        _eventController.text
                                      ];
                                    }
                                    prefs.setString("events", json.encode(encodeMap(_events)));
                                    scheduleNotification(_controller.selectedDay, _events[_controller.selectedDay].indexOf(_eventController.text) , _myclock, _eventController.toString());
                                    _controller.setSelectedDay(time_anfang);
                                  }

                                  _eventController.clear();
                                  Navigator.pop(context);
                                });
                                name_medical.clear();
                                dosage.clear();
                                note.clear();
                              }
                            }
                          },
                        )),
                  ],
                ))));
  }
}
