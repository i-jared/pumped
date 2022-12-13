import 'package:spotify_sdk/spotify_sdk.dart';

class MusicPlayer {
  Future<void> pause() async {
    await SpotifySdk.pause();
  }

  Future<void> seekTo(int mils) async {
    await SpotifySdk.seekTo(positionedMilliseconds: mils);
  }

  Future<void> play(String uri) async {
    await SpotifySdk.play(spotifyUri: uri);
  }
}
