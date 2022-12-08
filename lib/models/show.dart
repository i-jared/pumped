import 'package:hive_flutter/hive_flutter.dart';
import 'package:pumped/models/slide.dart';

part 'show.g.dart';

@HiveType(typeId: 0)
class Show {
  @HiveField(0)
  String title;
  @HiveField(1)
  List<Slide> slides;
  Show(this.title, this.slides);
  //TODO: add song;
}
