import 'dart:convert';
import '../util/helper.dart';

class CalendarData {
  final String id;
  final int begin_day;
  final int days_duration;
  final String name_medical;
  final String note;
  final String dosage;
  int interval;
  List<String> calendar_list = new List<String>();

  CalendarData({
    this.id,
    this.begin_day,
    this.days_duration,
    this.name_medical,
    this.note,
    this.dosage,
    this.interval
  });

  String get getID => id;
  int get getBeginDay => begin_day;
  int get getDayDuration => days_duration;
  String get getNameMedical => name_medical;
  String get getNote => note;
  String get getDosage => dosage;

/*
  String ListtoJson() {
    check_existing_calendar_data().then((data){
      if(data == false){
        var values = {
          "id": this.id,
          "begin_day": this.begin_day,
          "days_duration": this.days_duration,
          "name_medical": this.name_medical,
          "note": this.note,
          "dosage": this.dosage
        };
        return jsonEncode(values);
      }else{
        //read();
      }
    });
  }

  void read() async{
    var result;
    String events_calendar = await Helper.readDataFromsp('calendar_data');
    result = jsonDecode(events_calendar);
    print(result['begin_day']);
  }

  static Future<bool> check_existing_calendar_data() async {
    String calendar_data = await Helper.readDataFromsp('calendar_data');
    print('calendar_data_old');
    print(calendar_data);
    if(calendar_data != null){
      return true;
    }else{
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "begin_day": this.begin_day,
      "days_duration": this.days_duration,
      "name_medical": this.name_medical,
      "note": this.note,
      "dosage": this.dosage
    };
  }

  factory CalendarData.fromJson(Map<String, dynamic> parsedJson) {
    return CalendarData(
      id: parsedJson['id'],
      begin_day: parsedJson['begin_day'],
      days_duration: parsedJson['days_duration'],
      name_medical: parsedJson['name_medical'],
      note: parsedJson['note'],
      dosage: parsedJson['dosage']
    );
  }
*/

  String toJson() {
    var values = {
      "id": this.id,
      "begin_day": this.begin_day,
      "days_duration": this.days_duration,
      "name_medical": this.name_medical,
      "note": this.note,
      "dosage": this.dosage
    };
    return jsonEncode(values);
  }

}

