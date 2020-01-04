import 'dart:convert';
import '../util/helper.dart';

class CalendarData {
  final int id;
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

  int get getID => id;
  int get getBeginDay => begin_day;
  int get getDayDuration => days_duration;
  String get getNameMedical => name_medical;
  String get getNote => note;
  String get getDosage => dosage;

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


/*
  static Map<String, dynamic> toJson(DateTime begin_day, List infor) {
    return {
      "beginday": begin_day,
      "infor": infor
    };
  }

 */

/*
  factory CalendarData.fromJson(Map<String, dynamic> parsedJson) {
    return Medicine(
      notificationIDs: parsedJson['ids'],
      medicineName: parsedJson['name'],
      dosage: parsedJson['dosage'],
      medicineType: parsedJson['type'],
      interval: parsedJson['interval'],
      startTime: parsedJson['start'],
      startDay: parsedJson['startday'],
      endDay: parsedJson['endday'],
    );
  }

 */

}

