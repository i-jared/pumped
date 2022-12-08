import 'dart:io';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'slide.g.dart';

//@HiveType(typeId: 1)
abstract class Slide extends Equatable {}

@HiveType(typeId: 2)
class TextSlide extends Slide {
  @HiveField(20)
  final String text;
  @HiveField(21)
  final Color backgroundColor;
  @HiveField(22)
  final Color textColor;
  TextSlide(this.text, this.backgroundColor, this.textColor);

  @override
  List<Object?> get props => [text, backgroundColor, textColor];

  TextSlide copyWith({String? text, Color? backgroundColor, Color? textColor}) {
    return TextSlide(text ?? this.text, backgroundColor ?? this.backgroundColor,
        textColor ?? this.textColor);
  }
}

@HiveType(typeId: 3)
class ImageSlide extends Slide {
  @HiveField(30)
  final File? image;
  ImageSlide([this.image]);

  @override
  List<Object?> get props => [image];

  ImageSlide copyWith({File? image}) {
    return ImageSlide(image ?? this.image);
  }
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  Color read(BinaryReader reader) {
    return Color(reader.readInt());
  }

  @override
  int get typeId => 100;

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }
}

class FileAdapter extends TypeAdapter<File> {
  @override
  File read(BinaryReader reader) {
    return File(reader.readString());
  }

  @override
  int get typeId => 101;

  @override
  void write(BinaryWriter writer, File obj) {
    writer.writeString(obj.path);
  }
}
