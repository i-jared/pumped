import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/slide_type.dart';
import 'package:pumped/models/track.dart';
import 'package:pumped/state/create_show/create_show_state.dart';
import 'package:pumped/state/shows/shows_cubit.dart';

class CreateShowCubit extends Cubit<CreateShowState> {
  CreateShowCubit()
      : super(CreateShowState(uuid.v4(), const [], 0,
            TextSlide('Untitled', Colors.white, Colors.black)));

  void updateTitle(Slide slide) {
    emit(CreateShowState(
        state.uid, state.slides, state.currentSlide, slide, state.track));
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
    emit(CreateShowState(state.uid, updatedSlides, state.currentSlide,
        i < 0 ? updatedSlide : state.titleSlide, state.track));
  }

  void pickImage(int i) async {
    final ImagePicker picker = ImagePicker();

    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery);
    final File? file = xfile?.path == null ? null : File(xfile!.path);
    updateSlide(i, image: file);
  }

  void changeSlide(int i) {
    emit(CreateShowState(
        state.uid, state.slides, i, state.titleSlide, state.track));
  }

  void createSlide(SlideType type) {
    List<Slide> newSlides = List.from(state.slides)
      ..insert(
          state.currentSlide,
          type == SlideType.text
              ? TextSlide('', Colors.white, Colors.black)
              : ImageSlide());
    emit(CreateShowState(state.uid, newSlides, state.currentSlide,
        state.titleSlide, state.track));
  }

  Future<void> saveShow() async {
    emit(LoadingCreateShowState(state.uid, state.slides, state.currentSlide,
        state.titleSlide, state.track));
    final showsCubit = getIt<ShowsCubit>();
    await showsCubit
        .saveShow(Show(state.uid, state.titleSlide, state.slides, state.track));
    emit(CreateShowState(state.uid, state.slides, state.currentSlide,
        state.titleSlide, state.track));
  }

  void updateTrack(Track track) {
    emit(CreateShowState(
        state.uid, state.slides, state.currentSlide, state.titleSlide, track));
  }
}
