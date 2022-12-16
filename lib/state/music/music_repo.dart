import 'package:hive_flutter/hive_flutter.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/playlist.dart';
import 'package:pumped/models/track.dart';
import 'package:pumped/services/http_client.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class MusicRepo {
  final Box _box;
  final String tokenString = 'token';
  MusicRepo() : _box = Hive.box(hiveBoxName);
  Map<String, String> authHeader(String accessToken) {
    return {'Authorization': 'Bearer $accessToken'};
  }

  String? retrieveToken() {
    return _box.get(tokenString) as String?;
  }

  Future<String> login() async {
    final token = await SpotifySdk.getAccessToken(
        clientId: "4e3e62a6d9634ca2a0df0776fe823b57",
        redirectUrl: "pumped://",
        spotifyUri: "spotify:track:fakeuri",
        scope:
            "app-remote-control,user-modify-playback-state,playlist-read-private");
    await _box.put(tokenString, token);
    return token;
  }

  Future<List<Playlist>?> loadPlaylists(String accessToken) async {
    try {
      final result = await getIt<Api>().get(
          'https://api.spotify.com/v1/me/playlists', authHeader(accessToken));
      return List<Map<String, dynamic>>.from(result['items'])
          .map((p) => Playlist.fromSpotifyJson(p))
          .toList();
    } catch (e, stack) {
      logger.e('error in load data', e, stack);
      return null;
    }
  }

  Future<List<Track>?> loadPlaylist(
      String accessToken, String playlistId) async {
    try {
      final result = await getIt<Api>().get(
          'https://api.spotify.com/v1/playlists/$playlistId',
          authHeader(accessToken));
      return List<Map<String, dynamic>>.from(result['tracks']['items'])
          .map((p) => Track.fromSpotifyJson(p['track']))
          .toList();
    } catch (e, stack) {
      logger.e('error in load data', e, stack);
      return null;
    }
  }
}
