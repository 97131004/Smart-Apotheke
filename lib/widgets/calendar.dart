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
  //for notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Map<DateTime, List> _events = new Map<DateTime, List>();
  Map<DateTime, List> map_temporary = new Map<DateTime, List>();
  List _selectedEvents = new List();
  //for calendar
  CalendarController _calendarController;
  // variables are in the calendar form
  DateTime begin_day;
  TextEditingController days_duration = new TextEditingController();
  TextEditingController name_medical = new TextEditingController();
  TextEditingController note = new TextEditingController();
  TextEditingController dosage = new TextEditingController();
  TextEditingController text_show_date = new TextEditingController();//for the show of date ui picker

  var _selectedDay = DateTime.now();
  var _selectedDay1 = DateTime.now();
  var _selectedDay2 = DateTime.now();

  var result;
  var result2;

  void read() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    List<String> events_calendar = shared.getStringList('calendar_data');
    //await shared.clear(); //to remove all data
   //print(events_calendar);
    List<String> one_items = [];
    List<String> all_key_day = [];
    Map<DateTime, List> _events_tinhcv;

    if (events_calendar != null) {
      for (var i = 0; i < events_calendar.length; i++) {
        result = jsonDecode(events_calendar[i]);

        if (result['days_duration'] > 0) {
          for (var j = 0; j <= result['days_duration']; j++) {
            _selectedDay1 = new DateTime.fromMillisecondsSinceEpoch(result['begin_day']);

            all_key_day.add(_selectedDay1.add(Duration(days: result['days_duration'] - j)).toString());

          }
        }
          //one_items.add(result['name_medical'] + "-" + result['dosage'] + "-" + result['note']);
      }
    }

    List<String> same_key_day = [];
    for (var i = 0; i < all_key_day.length; i++)
    {
      for (var j = i + 1; j < all_key_day.length; j++)
      {
        if (all_key_day[i] == all_key_day[j])
        {
          same_key_day.add(all_key_day[i]);
          break;
        }
      }
    }

    if (events_calendar != null) {
      for (var i = 0; i < events_calendar.length; i++) {
        result = jsonDecode(events_calendar[i]);
        for (var j = 0; j <= result['days_duration']; j++) {
          _selectedDay1 = new DateTime.fromMillisecondsSinceEpoch(result['begin_day']);

          if(same_key_day.contains( _selectedDay1.add(Duration(days: result['days_duration'] - j)).toString())){
            one_items.add(result['name_medical'] + "-" + result['dosage'] + "-" + result['note']);
          }
        }
      }
    }
    print(same_key_day);
    final list = one_items;
    final seen = Set<String>();
    final common = list.where((str) => seen.add(str)).toList();
    //print(common);

    if (events_calendar != null) {
      List<String> item_local = [];
      for (var i = 0; i < events_calendar.length; i++) {
        result = jsonDecode(events_calendar[i]);
        print (result);
        if (result['days_duration'] > 0) {
          for (var j = 0; j <= result['days_duration']; j++) {
            if (result['begin_day'] > 0) {
              _selectedDay = new DateTime.fromMillisecondsSinceEpoch(result['begin_day']);
            }

              if(same_key_day.contains(_selectedDay.add(Duration(days: result['days_duration'] - j)).toString())){
                _events_tinhcv = {
                  _selectedDay.add(Duration(days: result['days_duration'] - j)): common
                };
              }else{
                  item_local = [(result['name_medical'] + "-" + result['dosage'] + "-" + result['note'])];
                  _events_tinhcv = {
                    _selectedDay.add(Duration(days: result['days_duration'] - j)): item_local
                  };
              }

            await _events.addAll(_events_tinhcv);
          }

        }
      }

      _selectedEvents = await cretateData(_events);
    }
  }

  Future<List> cretateData(Map<DateTime, List> _events) async {
    var data = new List();
    data = await _events[_selectedDay] ?? [];
    return data;
  }

  @override
  void initState() {
    read();
    super.initState();
    _calendarController = CalendarController();

    begin_day = DateTime.now();
    days_duration = TextEditingController();
    name_medical = TextEditingController();
    note = TextEditingController();
    dosage = TextEditingController();
    //for notifications
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');//image app icon
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    //for notifications
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => _build_form_to_calendar(context)),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          _buildTableCalendar(),
          //_buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          const SizedBox(height: 8.0),
          Expanded(
              child: _selectedEvents.isNotEmpty
                  ? _buildEventList()
                  : new Container(width: 0.0, height: 0.0)),
        ],
      )
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  _buildEventList() {
    if (_selectedEvents != null) {
      return ListView(
          children: _selectedEvents
              .map((event) => Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.8),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      title: Text(event.toString()),
                      onTap: () => print('$event tapped!'),
                    ),
                  ))
              .toList());
    }
  }

  @override
  Widget build_popup_form() {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              child: Text("Submit"),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
          },
          child: Text("Open Popup"),
        ),
      ),
    );
  }

  Widget _build_form_to_calendar (BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Events"),
      ),
      body:new  Padding(
         padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: text_show_date,
                  decoration: InputDecoration(hintText: 'Anfang *: '),
                  enabled: false,
                ),
                RaisedButton(
                  child: Text('Pick a date'),
                  onPressed: () {
                    showDatePicker(
                        context: context,
                        initialDate: begin_day == null ? DateTime.now() : begin_day,
                        firstDate: DateTime(2019),
                        lastDate: DateTime(2022)
                    ).then((date) {
                      setState(() {
                        begin_day = date;
                        text_show_date.text = begin_day != null ? begin_day.toString(): 'Anfang *: ';
                      });
                    });
                  },
                ),
                SizedBox(height: 20),
                Text('Tag aktiv *:'),
                TextField(
                  controller: days_duration,
                  decoration: InputDecoration(hintText: "Tag aktiv"),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Text('Medikament *:'),
                TextField(
                  controller: name_medical,
                  decoration: InputDecoration(hintText: "Name"),
                ),
                SizedBox(height: 20),
                Text('Dosage *:'),
                TextField(
                  controller: dosage,
                  decoration: InputDecoration(hintText: "3times/day"),
                ),
                SizedBox(height: 20),
                Text('Note:'),
                TextField(
                  controller: note,
                  decoration: InputDecoration(hintText: "Note"),
                ),
                SizedBox(height: 20),
                buildSaveButton(() => onPressedSaveButton()),
                SizedBox(
                  height: 20,
                ),
              ]),
          ),
    );
  }

  Future<void> _scheduleNotification(CalendarData data) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name',
        'repeatDailyAtTime description',
        importance: Importance.Max,
        sound: 'sound',
        priority: Priority.High,
        ledColor: Color(0xFF3EB16F),
        ledOffMs: 1000,
        ledOnMs: 1000,
        enableLights: true
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    for( var i = 1; i <= 3 ; i ++){
      if(i == 1){
        await flutterLocalNotificationsPlugin.showDailyAtTime(
            data.id,
            'Medikamentenerinnerungen: ${data.name_medical + data.dosage + data.note}',
            "Es ist an der Zeit, Ihre Medikamente gemäß Zeitplan einzunehmen",
            Time(9, 0, 0),
            platformChannelSpecifics);
      }
      if(i == 2){
        await flutterLocalNotificationsPlugin.showDailyAtTime(
            data.id,
            'Medikamentenerinnerungen: ${data.name_medical + data.dosage + data.note}',
            "Es ist an der Zeit, Ihre Medikamente gemäß Zeitplan einzunehmen",
            Time(12, 0, 0),
            platformChannelSpecifics);
      }
      if(i == 3){
        await flutterLocalNotificationsPlugin.showDailyAtTime(
            data.id,
            'Medikamentenerinnerungen: ${data.name_medical + data.dosage + data.note}',
            "Es ist an der Zeit, Ihre Medikamente gemäß Zeitplan einzunehmen",
            Time(18, 0, 0),
            platformChannelSpecifics);
      }
    }
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


  Widget buildSaveButton(Function onPressedFunc) {
    return ButtonTheme(
      buttonColor: Theme.of(context).accentColor,
      minWidth: double.infinity,
      height: 45.0,
      child: RaisedButton.icon(
        color: Colors.green,
        textColor: Colors.white,
        icon: Icon(Icons.save),
        onPressed: onPressedFunc,
        label: Text("Save"),
      ),
    );
  }

  void onPressedSaveButton() async {
    if (begin_day == days_duration.text ||
        days_duration.text == name_medical.text ||
        name_medical.text == dosage.text ||
        dosage.text == "") {
      _showDialog("Fehler", "Bitte füllen Sie alle Texte da oben");
    } else {
      int generate_id = _generatorIdUnique();
      CalendarData data = new CalendarData(
          id: generate_id,
          begin_day: begin_day.millisecondsSinceEpoch,
          days_duration: int.parse(days_duration.text),
          name_medical: name_medical.text,
          dosage: dosage.text,
          note: note.text);
      _scheduleNotification (data);

      _saveInformation(data.toJson());
    }
  }

  void _showDialog(String title, String body) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveInformation(data) async {
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    List<String> medicineJsonList = [];
    if (sharedUser.getStringList('calendar_data') == null) {
        medicineJsonList.add(data);
    } else {
      medicineJsonList = sharedUser.getStringList('calendar_data');
      medicineJsonList.add(data);
    }

    sharedUser.setStringList('calendar_data', medicineJsonList);
    Navigator.pop(context);
    initState();

  }

  int _generatorIdUnique() {
    Random random = new Random();
    int randomNumber = random.nextInt(1000);
    return randomNumber;
  }
}
