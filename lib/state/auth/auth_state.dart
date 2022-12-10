import 'package:equatable/equatable.dart';
import 'package:pumped/models/playlist.dart';
import 'package:pumped/models/track.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoggedOutAuthState extends AuthState {}

class LoggedInAuthState extends AuthState {
  final String accessToken;
  LoggedInAuthState(this.accessToken);

  @override
  List<Object?> get props => [accessToken];
}

class LoadingAuthState extends LoggedInAuthState {
  LoadingAuthState(String accessToken) : super(accessToken);
}

class ErrorAuthState extends LoggedInAuthState {
  final String message;
  ErrorAuthState(String accessToken, this.message) : super(accessToken);
}

class LoadedPlaylistsAuthState extends LoggedInAuthState {
  final List<Playlist> playlists;
  LoadedPlaylistsAuthState(String accessToken, this.playlists)
      : super(accessToken);
}

class LoadedTracksAuthState extends LoadedPlaylistsAuthState {
  final List<Track> tracks;
  LoadedTracksAuthState(
      String accessToken, List<Playlist> playlists, this.tracks)
      : super(accessToken, playlists);
}
