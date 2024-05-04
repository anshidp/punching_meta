import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:punching_machine/main.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AttendenceNotificationsSettings {
  Future<void> initNotification() async {}

  notificationsDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails("channelId", "channelName",
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    return notificationsPlugin.show(id, title, body, notificationsDetails());
  }

  onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {}

  void schduleNotification() async {
    PermissionStatus status = await Permission.notification.request();

    AndroidNotificationDetails androidDetail = const AndroidNotificationDetails(
        "notification", "notification",
        priority: Priority.max, importance: Importance.max);

    NotificationDetails noti = NotificationDetails(android: androidDetail);

    tz.initializeTimeZones();

    final timezone = tz.getLocation("Asia/Kolkata");

    final sheduleTime = DateTime.now().add(const Duration(hours: 8));

    var time = tz.TZDateTime.from(sheduleTime, timezone);

    await notificationsPlugin.zonedSchedule(
        0, "punchOut", "Your 8 hour working time completed", time, noti,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exact);
    print("9");
    //   // notification permission is granted
  }
}
