import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/playlist.dart';
import 'package:pumped/models/track.dart';
import 'package:pumped/services/music_player.dart';
import 'package:pumped/state/music/music_repo.dart';
import 'package:pumped/state/music/music_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class MusicAuthCubit extends Cubit<MusicAuthState> {
  final MusicRepo authRepo;
  MusicAuthCubit(this.authRepo) : super(LoggedOutMusicState());

  Future<void> connectRemote() async {
    try {
      if (state is! LoggedInMusicState) return;
      await SpotifySdk.connectToSpotifyRemote(
        accessToken: (state as LoggedInMusicState).accessToken,
        clientId: '4e3e62a6d9634ca2a0df0776fe823b57',
        redirectUrl: 'pumped://',
      );
    } catch (e, stack) {
      logger.w(' error connecting', e, stack);
      await login();
      await SpotifySdk.connectToSpotifyRemote(
        accessToken: (state as LoggedInMusicState).accessToken,
        clientId: '4e3e62a6d9634ca2a0df0776fe823b57',
        redirectUrl: 'pumped://',
      );
    }
  }

  Future<void> login([String? spotifyUri]) async {
    final accessToken = await authRepo.login(spotifyUri);
    // await connectRemote(accessToken);
    emit(LoggedInMusicState(accessToken));
  }

  void loadPlaylists() async {
    if (state is! LoggedInMusicState) {
      await login('spotify:track:doesnotexist');
    }
    String token = (state as LoggedInMusicState).accessToken;
    emit(LoadingMusicState(token));
    List<Playlist>? playlists = await authRepo.loadPlaylists(token);
    if (playlists == null) {
      token = await authRepo.login();
      emit(LoadingMusicState(token));
      playlists = await authRepo.loadPlaylists(token);
      if (playlists == null) {
        emit(ErrorMusicState(token, "error loading playlists"));
        return;
      }
    }
    emit(LoadedPlaylistsMusicState(token, playlists));
  }

  void loadPlaylistTracks(Playlist playlist) async {
    if (state is! LoadedPlaylistsMusicState) checkAuth();
    String token = (state as LoadedPlaylistsMusicState).accessToken;
    List<Playlist> playlists = (state as LoadedPlaylistsMusicState).playlists;
    emit(LoadingMusicState(token));
    List<Track>? tracks = await authRepo.loadPlaylist(token, playlist.id);
    if (tracks == null) {
      token = await authRepo.login();
      emit(LoadingMusicState(token));
      tracks = await authRepo.loadPlaylist(token, playlist.id);
      if (tracks == null) {
        // TODO inherit error authstate here from loadedplayliststate
        // TODO add listener that listens for error state and pushes an error toast
        emit(ErrorMusicState(token, "error loading tracks"));
        return;
      }
    }
    emit(LoadedTracksMusicState(token, playlists, tracks));
  }

  Future<void> checkAuth() async {
    // TODO implement
    return;
  }

  void goToPlaylists() {
    // TODO: show an error
    if (state is! LoadedPlaylistsMusicState) return;
    final lState = state as LoadedPlaylistsMusicState;
    emit(LoadedPlaylistsMusicState(lState.accessToken, lState.playlists));
  }

  void finishSongSelection() {
    if (state is LoggedInMusicState) {
      final authState = state as LoggedInMusicState;
      emit(FinishedTracksMusicState(authState.accessToken));
    } else {
      emit(LoggedOutMusicState());
    }
  }
}
