import 'package:equatable/equatable.dart';
import 'package:pumped/models/slide.dart';

class CreateShowState extends Equatable {
  final List<Slide> slides;
  final int currentSlide;

  const CreateShowState(this.slides, this.currentSlide);

  @override
  List<Object?> get props => [slides, currentSlide];

  // @override
  // bool operator ==(other) {
  //   print('in equals');
  //   print(other is CreateShowState &&
  //       other.slides.equals(slides) &&
  //       currentSlide == currentSlide);

  //   return other is CreateShowState &&
  //       other.slides.equals(slides) &&
  //       currentSlide == currentSlide;
  // }

  // @override
  // int get hashCode =>
  //     super.hashCode +
  //     currentSlide.hashCode +
  //     slides.fold(0, (l, s) => l + s.hashCode);
}

class LoadingCreateShowState extends CreateShowState {
  const LoadingCreateShowState(List<Slide> slides, int currentSlide)
      : super(slides, currentSlide);
}
