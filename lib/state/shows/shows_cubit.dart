import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/services/music_player.dart';
import 'package:pumped/state/shows/shows_repo.dart';
import 'package:pumped/state/shows/shows_state.dart';

class ShowsCubit extends Cubit<ShowsState> {
  final ShowsRepo showsRepo;
  Timer? timer;
  ShowsCubit(this.showsRepo) : super(LoadingShowsState()) {
    loadShows();
  }

  Future<void> loadShows() async {
    final shows = await showsRepo.loadShows();
    emit(LoadedShowsState(shows));
  }

  Future<void> createShow() async {}

  Future<void> saveShow(Show newShow) async {
    final List<Show> savedShows =
        (state is LoadedShowsState) ? (state as LoadedShowsState).shows : [];
    emit(LoadingShowsState());
    await showsRepo.saveShow(newShow);
    // TODO: notify of saving success
    emit(LoadedShowsState(
        [newShow, ...savedShows.where((s) => s.uid != newShow.uid)]));
  }

  Future<void> playShowTune(Show show) async {
    MusicPlayer musicPlayer = getIt<MusicPlayer>();
    if (show.track == null) return;
    await musicPlayer.play(show.track!.uri);
    final seekTo = (show.songStartRatio * show.track!.durationMils).floor();
    final playFor = ((show.songEndRatio * show.track!.durationMils) -
            (show.songStartRatio * show.track!.durationMils))
        .floor();
    if (seekTo > 0) {
      // If i don't delay it doesn't seek.
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await musicPlayer.seekTo(seekTo);
    timer = Timer.periodic(Duration(milliseconds: playFor), (_) async {
      await musicPlayer.seekTo(seekTo);
    });
  }

  void quitPlayback(Show show) {
    timer?.cancel();
    MusicPlayer musicPlayer = getIt<MusicPlayer>();
    if (show.track != null) musicPlayer.pause();
  }

  void edit() {
    emit(EditingShowsState((state as LoadedShowsState).shows));
  }

  void finishEdit() {
    emit(LoadedShowsState((state as LoadedShowsState).shows));
  }

  Future<void> removeShow(Show show) async {
    await showsRepo.removeShow(show);
    emit(EditingShowsState((state as EditingShowsState)
        .shows
        .where((s) => s.uid != show.uid)
        .toList()));
  }
}
