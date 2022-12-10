import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/playlist.dart';
import 'package:pumped/models/track.dart';
import 'package:pumped/state/auth/auth_repo.dart';
import 'package:pumped/state/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AuthCubit(this.authRepo) : super(LoggedOutAuthState()) {
    autoLogin();
  }

  void autoLogin() {
    final String? token = authRepo.retrieveToken();
    if (token != null) emit(LoggedInAuthState(token));
  }

  Future<void> login() async {
    final accessToken = await authRepo.login();
    emit(LoggedInAuthState(accessToken));
  }

  void loadPlaylists() async {
    if (state is! LoggedInAuthState) checkAuth();
    String token = (state as LoggedInAuthState).accessToken;
    emit(LoadingAuthState(token));
    List<Playlist>? playlists = await authRepo.loadPlaylists(token);
    if (playlists == null) {
      token = await authRepo.login();
      emit(LoadingAuthState(token));
      playlists = await authRepo.loadPlaylists(token);
      if (playlists == null) {
        emit(ErrorAuthState(token, "error loading playlists"));
        return;
      }
    }
    emit(LoadedPlaylistsAuthState(token, playlists));
  }

  void loadPlaylistTracks(Playlist playlist) async {
    if (state is! LoadedPlaylistsAuthState) checkAuth();
    String token = (state as LoadedPlaylistsAuthState).accessToken;
    List<Playlist> playlists = (state as LoadedPlaylistsAuthState).playlists;
    emit(LoadingAuthState(token));
    List<Track>? tracks = await authRepo.loadPlaylist(token, playlist.id);
    if (tracks == null) {
      token = await authRepo.login();
      emit(LoadingAuthState(token));
      tracks = await authRepo.loadPlaylist(token, playlist.id);
      if (tracks == null) {
        // TODO inherit error authstate here from loadedplayliststate
        // TODO add listener that listens for error state and pushes an error toast
        emit(ErrorAuthState(token, "error loading tracks"));
        return;
      }
    }
    emit(LoadedTracksAuthState(token, playlists, tracks));
  }

  Future<void> checkAuth() async {
    // TODO implement
    return;
  }

  void goToPlaylists() {
    if (state is! LoadedPlaylistsAuthState) return;
    final lState = state as LoadedPlaylistsAuthState;
    emit(LoadedPlaylistsAuthState(lState.accessToken, lState.playlists));
  }
}
