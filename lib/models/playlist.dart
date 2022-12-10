import 'package:collection/collection.dart';

class Playlist {
  String id;
  String name;
  String uri;
  String imageUrl;

  Playlist(
      {required this.id,
      required this.name,
      required this.uri,
      required this.imageUrl});

  factory Playlist.fromSpotifyJson(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        imageUrl:
            List<Map<String, dynamic>>.from(json['images']).firstOrNull?['url'],
        name: json['name'],
        uri: json['uri'],
      );

  @override
  String toString() => '{id: $id, name: $name, uri: $uri, imageUrl: $imageUrl}';
}
