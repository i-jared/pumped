import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/my_notification.dart';
import 'package:pumped/services/notify_service.dart';

class NotifyRepo {
  NotifyService notifyService;
  final Box _box;
  final String notificationsKey = 'notifications';
  NotifyRepo(this.notifyService) : _box = Hive.box(hiveBoxName);

  //
  Future<void> delete(String id) async {
    List<MyNotification> notifications =
        List<MyNotification>.from(_box.get(notificationsKey) ?? []);
    MyNotification? notification =
        notifications.firstWhereOrNull((n) => n.id == id);
    if (notification == null) return;
    cancelNotifications(notification.notificationIds);
    notifications.removeWhere((n) => n.id == id);
    _box.put(notificationsKey, notifications);
  }

  Future<void> deleteAll() async {
    // delete MyNotification objects from local db & cancel all notifs
    await notifyService.flutterLocalNotificationsPlugin.cancelAll();
    await _box.put(notificationsKey, []);
  }

  Future<MyNotification> create(Time time, List<Day> days, Show show) async {
    // create notification object in local db
    List<MyNotification> notifications =
        List<MyNotification>.from(_box.get(notificationsKey) ?? []);
    List<int> ids = List<int>.generate(days.length, (i) => uuid.v4().hashCode);
    scheduleNotifications(time, days, show.uid, ids);
    MyNotification newNotification =
        MyNotification(ids, days, time, show.uid, uuid.v4(), true);
    await _box.put(notificationsKey, [...notifications, newNotification]);
    return newNotification;
  }

  Future<void> scheduleNotifications(
      Time time, List<Day> days, String showUid, List<int> ids) async {
    for (int i = 0; i < days.length; i++) {
      // schedule notifications
      await notifyService.createNotification(ids[i], time, days[i], showUid);
    }
  }

  Future<void> cancelNotifications(List<int> ids) async {
    for (int notificationId in ids) {
      await notifyService.flutterLocalNotificationsPlugin
          .cancel(notificationId);
    }
  }

  Future<List<MyNotification>> loadNotifications() async {
    return List<MyNotification>.from(_box.get(notificationsKey) ?? []);
  }

  Future<bool> requestPermission() async {
    return await notifyService.requestPermission();
  }

  Future<void> activate(String id, bool active) async {
    List<MyNotification> notifications =
        List<MyNotification>.from(_box.get(notificationsKey) ?? []);
    MyNotification? notification =
        notifications.firstWhereOrNull((n) => n.id == id);
    if (notification == null) return;
    notifications.removeWhere((n) => n.id == id);
    _box.put(notificationsKey,
        [notification.copyWith(active: active), ...notifications]);
    // if active == true reschedule timer
    if (active) {
      await scheduleNotifications(notification.time, notification.weekdays,
          notification.showUid, notification.notificationIds);
    } else {
      // else cancel it
      await cancelNotifications(notification.notificationIds);
    }
  }
}
