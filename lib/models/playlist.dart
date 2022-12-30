import 'package:collection/collection.dart';

class Playlist {
  String id;
  String name;
  String uri;
  String? imageUrl;
  String? spotifyLink;

  Playlist({
    required this.id,
    required this.name,
    required this.uri,
    this.imageUrl,
    this.spotifyLink,
  });

  factory Playlist.fromSpotifyJson(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        imageUrl:
            List<Map<String, dynamic>>.from(json['images']).firstOrNull?['url'],
        name: json['name'],
        uri: json['uri'],
        spotifyLink: json['external_urls']['spotify'],
      );

  @override
  String toString() => '{id: $id, name: $name, uri: $uri, imageUrl: $imageUrl}';
}
