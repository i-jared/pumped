// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShowAdapter extends TypeAdapter<Show> {
  @override
  final int typeId = 0;

  @override
  Show read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Show(
      fields[0] as String,
      (fields[1] as List).cast<Slide>(),
    );
  }

  @override
  void write(BinaryWriter writer, Show obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.slides);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
