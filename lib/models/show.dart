import 'package:hive_flutter/hive_flutter.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/track.dart';

part 'show.g.dart';

@HiveType(typeId: 0)
class Show {
  @HiveField(3)
  String uid;
  @HiveField(0)
  Slide titleSlide;
  @HiveField(1)
  List<Slide> slides;
  @HiveField(2)
  Track? track;
  Show(this.uid, this.titleSlide, this.slides, [this.track]);
  //TODO: add song;
}

class TrackAdapter extends TypeAdapter<Track> {
  @override
  Track read(BinaryReader reader) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  int get typeId => 102;

  @override
  void write(BinaryWriter writer, Track obj) {
    // TODO: implement write
  }
}
