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
      fields[3] as String,
      fields[0] as Slide,
      (fields[1] as List).cast<Slide?>(),
      fields[2] as Track?,
      fields[4] as double,
      fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Show obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.titleSlide)
      ..writeByte(1)
      ..write(obj.slides)
      ..writeByte(2)
      ..write(obj.track)
      ..writeByte(3)
      ..write(obj.uid)
      ..writeByte(4)
      ..write(obj.songStartRatio)
      ..writeByte(5)
      ..write(obj.songEndRatio);
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
