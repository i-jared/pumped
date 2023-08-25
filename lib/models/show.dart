import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/track.dart';
import 'package:pumped/services/logger.dart';

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

  static Future<Show> fromFirestore(Map<String, dynamic> data) async {
    var uid = data['uid'];
    Slide titleSlide;
    if (data['titleSlide']['imageUrl'] != null) {
      var url = data['titleSlide']['imageUrl'];
      // download file. get path.
      logger.wtf('downloading image: $url');
      String? imageId;
      imageId = await ImageDownloader.downloadImage(url);
      logger.wtf(imageId);
      var path = await ImageDownloader.findPath(imageId!);
      logger.wtf(path);
      data['titleSlide']['imageUrl'] = path;
      titleSlide = ImageSlide.fromFirestore(data['titleSlide']);
    } else {
      titleSlide = TextSlide.fromFirestore(data['titleSlide']);
    }
    var slides =
        await Future.wait((data['slides'] as List<dynamic>).map((e) async {
      if (e['imageUrl'] != null) {
        var url = e['imageUrl'];
        // download file. get path
        var imageId = await ImageDownloader.downloadImage(url);
        var path = await ImageDownloader.findPath(imageId!);
        data['titleSlide']['imageUrl'] = path;
        e['imageUrl'] = path;
        return ImageSlide.fromFirestore(e);
      } else {
        return TextSlide.fromFirestore(e);
      }
    }).toList());
    var track = data['track']?['name'] == null
        ? null
        : Track.fromFirestore(data['track']);
    var songStartRatio = data['songStartRatio'];
    var songEndRatio = data['songEndRatio'];
    return Show(uid, titleSlide, slides, track, songStartRatio, songEndRatio);
  }
}
