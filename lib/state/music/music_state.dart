import 'package:equatable/equatable.dart';
import 'package:pumped/models/playlist.dart';
import 'package:pumped/models/track.dart';

abstract class MusicAuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoggedOutMusicState extends MusicAuthState {}

class LoggedInMusicState extends MusicAuthState {
  final String accessToken;
  LoggedInMusicState(this.accessToken);

  @override
  List<Object?> get props => [accessToken];
}

class LoadingMusicState extends LoggedInMusicState {
  LoadingMusicState(String accessToken) : super(accessToken);
}

class ErrorMusicState extends LoggedInMusicState {
  final String message;
  ErrorMusicState(String accessToken, this.message) : super(accessToken);
}

class LoadedPlaylistsMusicState extends LoggedInMusicState {
  final List<Playlist> playlists;
  LoadedPlaylistsMusicState(String accessToken, this.playlists)
      : super(accessToken);
}

class LoadedTracksMusicState extends LoadedPlaylistsMusicState {
  final List<Track> tracks;
  LoadedTracksMusicState(
      String accessToken, List<Playlist> playlists, this.tracks)
      : super(accessToken, playlists);
}

class FinishedTracksMusicState extends LoggedInMusicState {
  FinishedTracksMusicState(String accessToken) : super(accessToken);
}
