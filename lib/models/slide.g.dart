// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slide.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TextSlideAdapter extends TypeAdapter<TextSlide> {
  @override
  final int typeId = 2;

  @override
  TextSlide read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TextSlide(
      fields[20] as String,
      fields[21] as Color,
      fields[22] as Color,
    );
  }

  @override
  void write(BinaryWriter writer, TextSlide obj) {
    writer
      ..writeByte(3)
      ..writeByte(20)
      ..write(obj.text)
      ..writeByte(21)
      ..write(obj.backgroundColor)
      ..writeByte(22)
      ..write(obj.textColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextSlideAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ImageSlideAdapter extends TypeAdapter<ImageSlide> {
  @override
  final int typeId = 3;

  @override
  ImageSlide read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageSlide(
      fields[30] as File?,
    );
  }

  @override
  void write(BinaryWriter writer, ImageSlide obj) {
    writer
      ..writeByte(1)
      ..writeByte(30)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageSlideAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
