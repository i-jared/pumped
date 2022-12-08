import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/slide_type.dart';
import 'package:pumped/state/create_show/create_show_state.dart';
import 'package:pumped/state/shows/shows_cubit.dart';

class CreateShowCubit extends Cubit<CreateShowState> {
  CreateShowCubit() : super(const CreateShowState([], 0));

  void updateSlide(int i,
      {String? text, Color? backgroundColor, Color? textColor, File? image}) {
    final slide = state.slides[i];
    final updatedSlide = (slide is TextSlide)
        ? slide.copyWith(
            text: text, backgroundColor: backgroundColor, textColor: textColor)
        : (slide as ImageSlide).copyWith(image: image);
    final updatedSlides = List<Slide>.from(state.slides)..[i] = updatedSlide;
    emit(CreateShowState(updatedSlides, state.currentSlide));
  }

  void pickImage(int i) async {
    final ImagePicker picker = ImagePicker();

    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery);
    final File? file = xfile?.path == null ? null : File(xfile!.path);
    updateSlide(i, image: file);
  }

  void changeSlide(int i) {
    emit(CreateShowState(state.slides, i));
  }

  void createSlide(SlideType type) {
    List<Slide> newSlides = List.from(state.slides)
      ..insert(
          state.currentSlide,
          type == SlideType.text
              ? TextSlide('', Colors.white, Colors.black)
              : ImageSlide());
    emit(CreateShowState(newSlides, state.currentSlide));
  }

  Future<void> saveShow() async {
    emit(LoadingCreateShowState(state.slides, state.currentSlide));
    final showsCubit = getIt<ShowsCubit>();
    await showsCubit.saveShow(Show('', state.slides));
    emit(CreateShowState(state.slides, state.currentSlide));
  }
}
