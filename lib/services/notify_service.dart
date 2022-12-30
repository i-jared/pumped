import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/pages/view_show.dart';
import 'package:pumped/services/my_router.dart';
import 'package:pumped/state/shows/shows_repo.dart';
import 'package:timezone/data/latest_all.dart' as tza;
import 'package:timezone/timezone.dart' as tzb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifyService {
// register what will happen when you receive a notification
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidInitializationSettings initializationSettingsAndroid;
  late DarwinInitializationSettings initializationSettingsDarwin;
  late LinuxInitializationSettings initializationSettingsLinux;
  late InitializationSettings initializationSettings;

  NotifyService() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_launcher_foreground1');
    initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (_, __, ___, ____) {});
    initializationSettingsLinux = const LinuxInitializationSettings(
        defaultActionName: 'Open notification');
    initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);

    initialize();
  }

  Future<void> initialize() async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
    tza.initializeTimeZones();
    tzb.setLocalLocation(
        tzb.getLocation(await FlutterNativeTimezone.getLocalTimezone()));
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // handle payload. navigate to show
      final Show? show = await getIt<ShowsRepo>().getShowByUid(payload);
      if (show == null) return;
      MyRouter.navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (context) => ViewShow(show)));
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      return await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestPermission() ??
          false;
    }
    if (Platform.isIOS) {
      return await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    }
    if (Platform.isMacOS) {
      return await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    }
    return true;
  }

  Future<void> createNotification(
      int id, Time time, Day day, String payload) async {
    final now = tzb.TZDateTime.now(tzb.local);
    final newDayVal = day.value == 1 ? 7 : day.value - 1;
    final dayDif = (newDayVal - now.weekday) % 7;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Time to get pumped!',
      'You from the past wants you to watch this right now.',
      tzb.TZDateTime(
          tzb.local,
          now.year,
          now.month,
          now.add(Duration(days: dayDif)).day,
          time.hour,
          time.minute,
          time.second),
      const NotificationDetails(
          android: AndroidNotificationDetails(
              'Scheduled Notifications', 'Scheduled Notifications',
              channelDescription: 'Scheduled Notifications')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  Future<void> test() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      -1,
      'Time to get pumped!',
      'You from the past wants you to watch this right now.',
      tzb.TZDateTime.now(tzb.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
          android: AndroidNotificationDetails(
              'Scheduled Notifications', 'Scheduled Notifications',
              channelDescription: 'Scheduled Notifications')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'test',
    );
  }
}
