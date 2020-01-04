import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:maph_group3/util/calendar_data.dart';
import 'dart:math';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Calendar extends StatefulWidget {
  Calendar({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  final _formKey = GlobalKey<FormState>();//for validate input

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  TextEditingController _eventController;
  SharedPreferences prefs;

  // variables are in the calendar form
  TextEditingController name_medical = new TextEditingController();
  TextEditingController dosage = new TextEditingController();
  TextEditingController note = new TextEditingController();
  TextEditingController interval = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];
    initPrefs();

    name_medical = TextEditingController();
    note = TextEditingController();
    dosage = TextEditingController();
    interval = TextEditingController();
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _removeEvent;
            },
          ),
        ],
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
                  selectedColor: Theme.of (context).primaryColor,
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
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index){
                      final item = event;

                      return Dismissible(
                        // Each Dismissible must contain a Key. Keys allow Flutter to
                        // uniquely identify widgets.
                        key: Key(item),
                        // Provide a function that tells the app
                        // what to do after an item has been swiped away.
                        onDismissed: (direction) {
                          // Remove the item from the data source.
                          setState(() {
                            _selectedEvents.removeAt(index);
                            prefs.setString("events", json.encode(encodeMap(_events)));
                          });
                          // Then show a snackbar.
                          Scaffold.of(context)
                              .showSnackBar(SnackBar(content: Text("$item dismissed")));
                        },
                        // Show a red background as the item is swiped away.
                        background: Container(color: Colors.red),
                        child: ListTile(title: Text('$item')),
                      );
                    }
                ),
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

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
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
                    decoration: InputDecoration(labelText: 'Medikament Name'),
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
                    decoration: InputDecoration(labelText: 'Dosage'),
                    controller: dosage,
                  ),
                  SizedBox(height: 20),
                    TextFormField(
                    decoration: InputDecoration(labelText: 'Note'),
                    controller: note,
                  ),
                  Container(
                    margin: EdgeInsets.all(70),
                    child:FlatButton(
                      color: Colors.teal,
                      child: Text("Save",
                        style: TextStyle(
                            color: Colors.white
                        ),),
                      onPressed: () {
                        if(_formKey.currentState.validate()){
                          if(note.text != null){
                            _eventController.text = name_medical.text + "-- " + dosage.text + "--" + note.text;
                          }else{
                            _eventController.text = name_medical.text + "--" + dosage.text;
                          }

                          if(_eventController.text != null && _eventController.text != ""){
                            setState(() {
                              if (_events[_controller.selectedDay] != null) {
                                _events[_controller.selectedDay].add(_eventController.text);
                              } else {
                                _events[_controller.selectedDay] = [
                                  _eventController.text
                                ];
                              }
                              prefs.setString("events", json.encode(encodeMap(_events)));
                              _eventController.clear();
                              Navigator.pop(context);
                            });
                            name_medical.clear();
                            dosage.clear();
                            note.clear();
                          }
                        }

                      },
                    )
                  ),
                ],
              )
              ))
    );
  }

  /*
  Function to remove a event in a day
   */
  _removeEvent(){

    print(_controller.selectedDay);
  }
}