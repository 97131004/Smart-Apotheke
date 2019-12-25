import 'dart:convert';
import 'package:maph_group3/util/calendar_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalBloc {
  BehaviorSubject<List<CalendarData>> _medicineList$;
  BehaviorSubject<List<CalendarData>> get medicineList$ => _medicineList$;

  GlobalBloc() {
    _medicineList$ = BehaviorSubject<List<CalendarData>>.seeded([]);
    //makeMedicineList();
  }
/*
  Future removeMedicine(CalendarData tobeRemoved) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    List<String> medicineJsonList = [];

    var blocList = _medicineList$.value;
    blocList.removeWhere(
        (medicine) => medicine.name_medical == tobeRemoved.name_medical);

    for (int i = 0; i < (24 / tobeRemoved.interval).floor(); i++) {
      flutterLocalNotificationsPlugin
          .cancel(int.parse(tobeRemoved.id[i]));
    }
    if (blocList.length != 0) {
      for (var blocMedicine in blocList) {
        String medicineJson = jsonEncode(blocMedicine.toJson());
        medicineJsonList.add(medicineJson);
      }
    }
    sharedUser.setStringList('medicines', medicineJsonList);
    _medicineList$.add(blocList);
  }
/*
  Future updateMedicineList(CalendarData newMedicine) async {
    var blocList = _medicineList$.value;
    blocList.add(newMedicine);
    _medicineList$.add(blocList);
    Map<String, dynamic> tempMap = newMedicine.toJson();
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    String newMedicineJson = jsonEncode(tempMap);
    List<String> medicineJsonList = [];
    if (sharedUser.getStringList('medicines') == null) {
      medicineJsonList.add(newMedicineJson);
    } else {
      medicineJsonList = sharedUser.getStringList('medicines');
      medicineJsonList.add(newMedicineJson);
    }
    sharedUser.setStringList('medicines', medicineJsonList);
  }
*/
  Future makeMedicineList() async {
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    List<String> jsonList = sharedUser.getStringList('medicines');
    List<CalendarData> prefList = [];
    if (jsonList == null) {
      return;
    } else {
      for (String jsonMedicine in jsonList) {
        Map userMap = jsonDecode(jsonMedicine);
        CalendarData tempMedicine = CalendarData.fromJson(userMap);
        prefList.add(tempMedicine);
      }
      _medicineList$.add(prefList);
    }
  }

  void dispose() {
    _medicineList$.close();
  }

 */
}
