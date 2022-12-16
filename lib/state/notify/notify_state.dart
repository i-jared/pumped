import 'package:equatable/equatable.dart';
import 'package:pumped/models/my_notification.dart';

class NotifyState extends Equatable {
  final bool? hasPermission;
  const NotifyState(this.hasPermission);

  @override
  List<Object?> get props => [hasPermission];
}

class LoadingNotifyState extends NotifyState {
  const LoadingNotifyState(bool? hasPermission) : super(hasPermission);
}

class LoadedNotifyState extends NotifyState {
  final List<MyNotification> notifications;
  const LoadedNotifyState(bool? hasPermission, this.notifications)
      : super(hasPermission);

  @override
  List<Object?> get props => [notifications];
}
