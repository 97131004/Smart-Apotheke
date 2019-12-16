import 'dart:convert';

class CalendarData {
  final String id;
  final int begin_day;
  final int days_duration;
  final String name_medical;
  final String note;
  final String dosage;

  CalendarData({
    this.id,
    this.begin_day,
    this.days_duration,
    this.name_medical,
    this.note,
    this.dosage
  });

  String get getID => id;
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



//  factory CalendarData.fromJson(Map<String, dynamic> parsedJson) {
//    return CalendarData(
//      id: parsedJson['id'],
//      begin_day: parsedJson['beginday'],
//      days_duration: parsedJson['days_duration'],
//      name_medical: parsedJson['name_medical'],
//      note: parsedJson['note'],
//      dosage: parsedJson['dosage'],
//    );
//  }


}

