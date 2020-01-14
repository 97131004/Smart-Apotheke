import 'package:maph_group3/widgets/calendar.dart';
import 'package:test/test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  const id = 0;
  const title = 'title';
  const body = 'body';
  const payload = 'payload';

  group('android', () {
    final calendar = Calendar();

    test('showDailyAtTime in Notifications', () async {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name',
        'repeatDailyAtTime description',
        importance: Importance.Max,
        sound: 'sound',
        ledOffMs: 1000,
        ledOnMs: 1000,
        enableLights: true,
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      int year = 2019;
      int month = 1;
      int day = 13;

      await flutterLocalNotificationsPlugin.showDailyAtTime(
          11419,
          'Medikamente: 123',
          'Es ist an der Zeit, Ihre Medikamente gemäß Zeitplan einzunehmen',
          Time(10, 0, 0),
          platformChannelSpecifics);
    });

  });
}