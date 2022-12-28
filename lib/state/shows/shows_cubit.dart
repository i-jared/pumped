import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/services/music_player.dart';
import 'package:pumped/services/toast.dart';
import 'package:pumped/state/music/music_cubit.dart';
import 'package:pumped/state/music/music_state.dart';
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
    await getIt<MusicAuthCubit>().connectRemote();
    musicPlayer.play(show.track!.uri);
    final seekTo = (show.songStartRatio * show.track!.durationMils).floor();
    final playFor = ((show.songEndRatio * show.track!.durationMils) -
            (show.songStartRatio * show.track!.durationMils))
        .floor();
    await Future.delayed(
        const Duration(milliseconds: 200), () => musicPlayer.seekTo(seekTo));
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
    if (state is! EditingShowsState) {
      showToast('Error removing show');
      return;
    }
    if ((state as EditingShowsState).shows.length == 1) {
      emit(LoadedShowsState(const []));
      return;
    }
    emit(EditingShowsState((state as EditingShowsState)
        .shows
        .where((s) => s.uid != show.uid)
        .toList()));
  }
}
