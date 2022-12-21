import 'package:hive_flutter/hive_flutter.dart';

part 'track.g.dart';

@HiveType(typeId: 4)
class Track {
  @HiveField(40)
  String name;
  @HiveField(41)
  String artist;
  @HiveField(42)
  String uri;
  @HiveField(43)
  String imageUrl;
  @HiveField(44)
  int durationMils;
  String? spotifyLink;
  Track({
    required this.name,
    required this.artist,
    required this.uri,
    required this.imageUrl,
    required this.durationMils,
    this.spotifyLink,
  });

  factory Track.fromSpotifyJson(Map<String, dynamic> json) => Track(
      artist: List<Map<String, dynamic>>.from(json['artists']).first['name'],
      imageUrl:
          List<Map<String, dynamic>>.from(json['album']['images']).first['url'],
      name: json['name'],
      uri: json['uri'],
      durationMils: json['duration_ms'],
      spotifyLink:
          'https://open.spotify.com/track/${json['uri'].split(':')[2]}');
}
