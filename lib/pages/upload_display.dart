import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/state/shows/shows_cubit.dart';
import 'package:pumped/state/shows/shows_state.dart';
import 'package:pumped/state/uploading/uploading_cubit.dart';
import 'package:pumped/state/uploading/uploading_state.dart';

class UploadDisplay extends StatelessWidget {
  const UploadDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => UploadingCubit(),
        child: Builder(
          builder: (context) => _build(context),
        ));
  }

  Widget _build(BuildContext context) {
    final showsCubit = context.watch<ShowsCubit>();
    final uploadingCubit = context.watch<UploadingCubit>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Upload Shows').mood(),
        ),
        body: showsCubit.state is LoadingShowsState
            ? _buildLoading()
            : _buildShows(showsCubit, uploadingCubit, context),
        floatingActionButton: FloatingActionButton.large(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.black,
            onPressed: uploadingCubit.state is LoadingUploadingState ||
                    listEquals(uploadingCubit.initialShows,
                        uploadingCubit.state.selectedShows)
                ? null
                : () => uploadingCubit.upload(),
            tooltip: 'Upload Show',
            child: uploadingCubit.state is LoadingUploadingState
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.rocket, size: 80, color: Colors.white)
                    .rotate(angle: 3.14 / 4)));
  }

  Widget _buildLoading() => const CircularProgressIndicator().center();
  Widget _buildShows(
      ShowsCubit showsCubit, UploadingCubit uploadingCubit, context) {
    final showsState = showsCubit.state as LoadedShowsState;
    if (showsState.shows.isEmpty) {
      return const Text('No Shows Yet...').alone();
    }
    var width = MediaQuery.of(context).size.width / 3;
    return Wrap(
        children: showsState.shows.map((show) {
      Slide slide = show.titleSlide;
      bool isText = show.titleSlide is TextSlide;
      return Container(
          height: width,
          width: width,
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
                border: uploadingCubit.state.selectedShows.contains(show)
                    ? Border.all(color: Colors.deepOrange, width: 2)
                    : null,
                color: isText ? (slide as TextSlide).backgroundColor : null,
                image: !isText
                    ? DecorationImage(
                        image: FileImage((slide as ImageSlide).image!),
                        fit: BoxFit.cover)
                    : null),
            child: isText
                ? AutoSizeText(
                    (slide as TextSlide).text,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ).center()
                : null,
          ).gestures(onTap: () => uploadingCubit.selectShow(show)));
    }).toList());
  }
}
