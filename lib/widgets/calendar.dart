import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:maph_group3/util/calendar_data.dart';
import 'package:uuid/uuid.dart';
import '../util/helper.dart';
import 'dart:convert';

class Calendar extends StatefulWidget {
  Calendar({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  Map<DateTime, List> _events = new Map<DateTime, List>();
  List _selectedEvents = new List();

  CalendarController _calendarController;

  DateTime begin_day;
  TextEditingController days_duration = new TextEditingController();
  TextEditingController name_medical = new TextEditingController();
  TextEditingController note = new TextEditingController();
  TextEditingController dosage = new TextEditingController();

  var _selectedDay = DateTime.now();

  var result;

  void read() async {
    String events_calendar = await Helper.readDataFromsp('calendar_data');
    result = jsonDecode(events_calendar);
    List<String> one_items = [];
    Map<DateTime, List> _events_tinhcv;
    if(result['begin_day'] > 0){
      _selectedDay = new DateTime.fromMillisecondsSinceEpoch( result['begin_day']);
    }
    for(var i = 1 ; i <= result['days_duration'] ; i++){
      if(i == 1){
        one_items.add(result['name_medical'] + "-" + result['note'] + "-" + result['dosage']);
      }

      _events_tinhcv = {
        _selectedDay.add(Duration(days: result['days_duration'] - i)): one_items
      };
      await _events.addAll(_events_tinhcv);
    }
    _selectedEvents = await cretateData(_events);
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
      DateTime first, DateTime last, CalendarFormat format) {
  }

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
                    builder: (context) => _build_form_to_calendar()),
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

          const SizedBox(height: 8.0),
          const SizedBox(height: 8.0),
          Expanded(child:  _selectedEvents.isNotEmpty ? _buildEventList() : new Container(width: 0.0, height: 0.0)),
        ],
      ),
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
    if(_selectedEvents != null){
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

  Widget _build_form_to_calendar() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Events"),
      ),
      body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Anfang *:' + begin_day.toString()),
            RaisedButton(
                child: Text("Pick a date"),
                onPressed: () {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2019),
                          lastDate: DateTime(2029))
                      .then((date) {
                    setState(() {
                      begin_day = date;
                    });
                  });
                }),
            SizedBox(height: 20),
            Text('Zeit Dauern *:'),
            TextField(
              controller: days_duration,
              decoration: InputDecoration(hintText: "zeit dauert"),
            ),
            SizedBox(height: 20),
            Text('Medikament *:'),
            TextField(
              controller: name_medical,
              decoration: InputDecoration(hintText: "name"),
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
              decoration: InputDecoration(hintText: "note"),
            ),
            SizedBox(height: 20),
            buildSaveButton(() => onPressedSaveButton()),
            SizedBox(
              height: 20,
            ),
          ]),
    );
  }

  Widget buildSaveButton(Function onPressedFunc) {
    return ButtonTheme(
      buttonColor: Theme.of(context).accentColor,
      minWidth: double.infinity,
      height: 40.0,
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
      String generate_id = _generatorIdUnique();

      CalendarData data = new CalendarData(
          id: generate_id,
          begin_day: begin_day.millisecondsSinceEpoch,
          days_duration: int.parse(days_duration.text),
          name_medical: name_medical.text,
          dosage: dosage.text,
          note: note.text);
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

  void _saveInformation(data) {
    Helper.writeDatatoSp('calendar_data', data);
    /*if(old_string.length > 0){
      //Helper.updateStringSF('calendar_data', old_string, 'calendar_data', data);
    }else{
      print('add');
      //Helper.addStringToSF('calendar_data', data);
    }*/

    // scheduleNotification(newEntryMedicine);
    Navigator.pop(context);
    initState();
  }

  String _generatorIdUnique() {
    var uuid = new Uuid();

    String id = uuid.v4();
    return id;
  }
}
