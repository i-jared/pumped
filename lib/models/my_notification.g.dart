// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_notification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MyNotificationAdapter extends TypeAdapter<MyNotification> {
  @override
  final int typeId = 5;

  @override
  MyNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MyNotification(
      (fields[50] as List).cast<int>(),
      (fields[51] as List).cast<Day>(),
      fields[52] as Time,
      fields[53] as String,
      fields[54] as String,
      fields[55] == null ? true : fields[55] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MyNotification obj) {
    writer
      ..writeByte(6)
      ..writeByte(50)
      ..write(obj.notificationIds)
      ..writeByte(51)
      ..write(obj.weekdays)
      ..writeByte(52)
      ..write(obj.time)
      ..writeByte(53)
      ..write(obj.showUid)
      ..writeByte(54)
      ..write(obj.id)
      ..writeByte(55)
      ..write(obj.active);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
