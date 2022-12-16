import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/my_notification.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/state/notify/notify_repo.dart';
import 'package:pumped/state/notify/notify_state.dart';

class NotifyCubit extends Cubit<NotifyState> {
  NotifyRepo notifyRepo;
  NotifyCubit(this.notifyRepo) : super(const LoadingNotifyState(null)) {
    init();
  }

  Future<void> init() async {
    bool? permission;
    if (state.hasPermission == null) {
      permission = await notifyRepo.requestPermission();
      emit(LoadingNotifyState(permission));
    }
    if (state is LoadingNotifyState) {
      List<MyNotification> notifications = await notifyRepo.loadNotifications();
      emit(LoadedNotifyState(permission, notifications));
    }
  }

  Future<void> create(Time time, List<Day> days, Show show) async {
    if (state is! LoadedNotifyState) return;
    // TODO emit error state
    final MyNotification newNotification =
        await notifyRepo.create(time, days, show);
    // TODO catch errors everytwhere in repo and emit error state
    emit(LoadedNotifyState(state.hasPermission,
        [...(state as LoadedNotifyState).notifications, newNotification]));
  }

  Future<void> deleteAll() async {
    if (state is! LoadedNotifyState) return;
    await notifyRepo.deleteAll();
    emit(LoadedNotifyState(state.hasPermission, const []));
  }

// delete any notifications when you delete a show
  Future<void> delete(MyNotification notification) async {
    if (state is! LoadedNotifyState) return;
    await notifyRepo.delete(notification.id);
    emit(LoadedNotifyState(
        state.hasPermission,
        (state as LoadedNotifyState)
            .notifications
            .where((n) => n.id != notification.id)
            .toList()));
  }

  Future<void> activate(MyNotification notif) async {
    await notifyRepo.activate(notif.id, true);
    List<MyNotification> notifications =
        List<MyNotification>.from((state as LoadedNotifyState).notifications);
    int i = notifications.indexOf(notif);
    notifications.removeAt(i);
    notifications.insert(i, notif.copyWith(active: true));
    emit(LoadedNotifyState(state.hasPermission, notifications));
  }

  Future<void> deactivate(MyNotification notif) async {
    await notifyRepo.activate(notif.id, false);
    List<MyNotification> notifications =
        List<MyNotification>.from((state as LoadedNotifyState).notifications);
    int i = notifications.indexOf(notif);
    notifications.removeAt(i);
    notifications.insert(i, notif.copyWith(active: false));
    emit(LoadedNotifyState(state.hasPermission, notifications));
  }
}
