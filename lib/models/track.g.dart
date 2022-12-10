// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 4;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track(
      name: fields[40] as String,
      artist: fields[41] as String,
      uri: fields[42] as String,
      imageUrl: fields[43] as String,
      durationMils: fields[44] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(5)
      ..writeByte(40)
      ..write(obj.name)
      ..writeByte(41)
      ..write(obj.artist)
      ..writeByte(42)
      ..write(obj.uri)
      ..writeByte(43)
      ..write(obj.imageUrl)
      ..writeByte(44)
      ..write(obj.durationMils);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
