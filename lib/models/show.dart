import 'package:hive_flutter/hive_flutter.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/track.dart';

part 'show.g.dart';

@HiveType(typeId: 0)
class Show {
  @HiveField(0)
  Slide titleSlide;
  @HiveField(1)
  List<Slide?> slides;
  @HiveField(2)
  Track? track;
  @HiveField(3)
  String uid;
  @HiveField(4)
  double songStartRatio;
  @HiveField(5)
  double songEndRatio;
  Show(this.uid, this.titleSlide, this.slides,
      [this.track, this.songStartRatio = 0.0, this.songEndRatio = 1.0]);

  @override
  String toString() {
    return '{uid: $uid}';
  }
}
