import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/slide_type.dart';
import 'package:pumped/models/track.dart';
import 'package:pumped/services/music_player.dart';
import 'package:pumped/services/my_router.dart';
import 'package:pumped/services/toast.dart';
import 'package:pumped/state/create_show/create_show_state.dart';
import 'package:pumped/state/shows/shows_cubit.dart';

class CreateShowCubit extends Cubit<CreateShowState> {
  Timer? timer;
  CreateShowCubit([Show? show])
      : super(CreateShowState(
            show?.uid ?? uuid.v4(),
            show?.slides ?? const [],
            0,
            show?.titleSlide ??
                TextSlide('Untitled', Colors.white, Colors.black),
            show?.track,
            show?.songStartRatio ?? 0.0,
            show?.songEndRatio ?? 1.0));

  void updateTitle(Slide slide) {
    emit(CreateShowState(state.uid, state.slides, state.currentSlide, slide,
        state.track, state.songStartRatio, state.songEndRatio));
  }

  void updateSlide(int i,
      {String? text, Color? backgroundColor, Color? textColor, File? image}) {
    final slide = i >= 0 ? state.slides[i] : state.titleSlide;

    final updatedSlide = (slide is TextSlide)
        ? slide.copyWith(
            text: text, backgroundColor: backgroundColor, textColor: textColor)
        : (slide as ImageSlide).copyWith(image: image);
    final updatedSlides = List<Slide>.from(state.slides);
    if (i >= 0) updatedSlides[i] = updatedSlide;
    emit(state.copyWith(
      slides: updatedSlides,
      titleSlide: i < 0 ? updatedSlide : state.titleSlide,
    ));
  }

  void pickImage(int i) async {
    final ImagePicker picker = ImagePicker();

    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery);
    final File? file = xfile?.path == null ? null : File(xfile!.path);
    updateSlide(i, image: file);
  }

  void changeSlide(int i) {
    emit(state.copyWith(currentSlide: i));
  }

  void createSlide(SlideType type) {
    List<Slide?> newSlides = List<Slide?>.from(state.slides);
    Slide newSlide = type == SlideType.text
        ? TextSlide('', Colors.white, Colors.black)
        : ImageSlide();
    if (state.currentSlide < state.slides.length &&
        state.slides[state.currentSlide] == null) {
      newSlides
          .replaceRange(state.currentSlide, state.currentSlide + 1, [newSlide]);
    } else {
      newSlides.insert(state.currentSlide, newSlide);
    }

    emit(state.copyWith(slides: newSlides));
  }

  Future<void> saveShow() async {
    emit(LoadingCreateShowState.fromCreateShowState(state));
    final showsCubit = getIt<ShowsCubit>();
    await showsCubit.saveShow(Show(state.uid, state.titleSlide, state.slides,
        state.track, state.songStartRatio, state.songEndRatio));
    emit(CreateShowState.fromCreateShowState(state));
    showToast('Show saved');
  }

  void updateTrack(Track track) {
    emit(state.copyWith(track: track, songEndRatio: 1.0, songStartRatio: 0.0));
  }

  void pausePlayback() async {
    // place below code in pause playback
    await getIt<MusicPlayer>().pause();
    timer?.cancel();
  }

  Future<bool> selectedSongPreview() async {
    try {
      if (state.track == null) return false;
      MusicPlayer musicPlayer = getIt<MusicPlayer>();
      await musicPlayer.play(state.track!.uri);
      final seekTo = (state.songStartRatio * state.track!.durationMils).floor();
      final playFor = ((state.songEndRatio * state.track!.durationMils) -
              (state.songStartRatio * state.track!.durationMils))
          .floor();
      if (seekTo > 0) {
        // If i don't delay it doesn't seek.
        await Future.delayed(const Duration(milliseconds: 100));
        await musicPlayer.seekTo(seekTo);
        timer = Timer(Duration(milliseconds: playFor), () async {
          await musicPlayer.pause();
          timer?.cancel();
        });
      }
      return true;
    } catch (e, stack) {
      MyRouter.showErrorSnackBar('Error playing song');
      logger.e('error playing song', e, stack);
      return false;
    }
  }

  void updateSong(
      {Track? track, double? songStartRatio, double? songEndRatio}) {
    final double newStartRatio =
        max(min(songStartRatio ?? state.songStartRatio, state.songEndRatio), 0);
    final double newEndRatio =
        max(min(songEndRatio ?? state.songEndRatio, 1), state.songStartRatio);

    emit(state.copyWith(
        track: track,
        songStartRatio: newStartRatio,
        songEndRatio: newEndRatio));
  }

  void deleteSlide(int i) {
    List<Slide> newSlides = List<Slide>.from(state.slides);
    newSlides.removeAt(i);
    emit(state.copyWith(slides: newSlides));
  }

  void resetSlide(int i) {
    List<Slide?> newSlides = List<Slide?>.from(state.slides);
    newSlides.replaceRange(i, i + 1, [null]);
    emit(state.copyWith(slides: newSlides));
  }
}
