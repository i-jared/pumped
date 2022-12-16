import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:hive_flutter/hive_flutter.dart';

part 'my_notification.g.dart';

@HiveType(typeId: 5)
class MyNotification extends Equatable {
  @HiveField(50)
  final List<int> notificationIds;
  @HiveField(51)
  final List<Day> weekdays;
  @HiveField(52)
  final Time time;
  @HiveField(53)
  final String showUid;
  @HiveField(54)
  final String id;
  @HiveField(55, defaultValue: true)
  final bool active;

  const MyNotification(this.notificationIds, this.weekdays, this.time,
      this.showUid, this.id, this.active);

  MyNotification copyWith({
    List<int>? notificationIds,
    List<Day>? weekdays,
    Time? time,
    String? showUid,
    String? id,
    bool? active,
  }) {
    return MyNotification(
        notificationIds ?? this.notificationIds,
        weekdays ?? this.weekdays,
        time ?? this.time,
        showUid ?? this.showUid,
        id ?? this.id,
        active ?? this.active);
  }

  @override
  List<Object?> get props =>
      [notificationIds, weekdays, time, showUid, id, active];
}

class TimeAdapter extends TypeAdapter<Time> {
  @override
  Time read(BinaryReader reader) {
    return Time(reader.readInt(), reader.readInt(), reader.readInt());
  }

  @override
  int get typeId => 103;

  @override
  void write(BinaryWriter writer, Time obj) {
    writer.writeInt(obj.hour);
    writer.writeInt(obj.minute);
    writer.writeInt(obj.second);
  }
}

class DayAdapter extends TypeAdapter<Day> {
  @override
  Day read(BinaryReader reader) {
    return Day(reader.readInt());
  }

  @override
  int get typeId => 102;

  @override
  void write(BinaryWriter writer, Day obj) {
    writer.writeInt(obj.value);
  }
}
