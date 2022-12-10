import 'package:equatable/equatable.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/track.dart';
import 'package:uuid/uuid.dart';

class CreateShowState extends Equatable {
  final Track? track;
  final List<Slide> slides;
  final Slide titleSlide;
  final int currentSlide;
  final String uid;

  const CreateShowState(
      this.uid, this.slides, this.currentSlide, this.titleSlide,
      [this.track]);

  @override
  List<Object?> get props => [uid, slides, currentSlide, titleSlide, track];
}

class LoadingCreateShowState extends CreateShowState {
  const LoadingCreateShowState(
      String uid, List<Slide> slides, int currentSlide, Slide titleSlide,
      [Track? track])
      : super(uid, slides, currentSlide, titleSlide, track);
}
