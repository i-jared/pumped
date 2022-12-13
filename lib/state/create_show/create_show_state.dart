import 'package:equatable/equatable.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/track.dart';

class CreateShowState extends Equatable {
  final Track? track;
  final double songStartRatio;
  final double songEndRatio;
  final List<Slide?> slides;
  final Slide titleSlide;
  final int currentSlide;
  final String uid;

  const CreateShowState(
      this.uid, this.slides, this.currentSlide, this.titleSlide,
      [this.track, this.songStartRatio = 0.0, this.songEndRatio = 1.0]);

  CreateShowState copyWith({
    Track? track,
    double? songStartRatio,
    double? songEndRatio,
    List<Slide?>? slides,
    Slide? titleSlide,
    int? currentSlide,
    String? uid,
  }) {
    return CreateShowState(
        uid ?? this.uid,
        slides ?? this.slides,
        currentSlide ?? this.currentSlide,
        titleSlide ?? this.titleSlide,
        track ?? this.track,
        songStartRatio ?? this.songStartRatio,
        songEndRatio ?? this.songEndRatio);
  }

  factory CreateShowState.fromCreateShowState(CreateShowState state) {
    return CreateShowState(
        state.uid,
        state.slides,
        state.currentSlide,
        state.titleSlide,
        state.track,
        state.songStartRatio,
        state.songEndRatio);
  }

  @override
  List<Object?> get props => [
        uid,
        slides,
        currentSlide,
        titleSlide,
        track,
        songEndRatio,
        songStartRatio
      ];
}

class LoadingCreateShowState extends CreateShowState {
  const LoadingCreateShowState(
      String uid, List<Slide?> slides, int currentSlide, Slide titleSlide,
      [Track? track, double songStartRatio = 0.0, double songEndRatio = 1.0])
      : super(uid, slides, currentSlide, titleSlide, track, songStartRatio,
            songEndRatio);

  factory LoadingCreateShowState.fromCreateShowState(CreateShowState state) {
    return LoadingCreateShowState(
        state.uid,
        state.slides,
        state.currentSlide,
        state.titleSlide,
        state.track,
        state.songStartRatio,
        state.songEndRatio);
  }
}
