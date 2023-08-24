import 'package:equatable/equatable.dart';
import 'package:pumped/models/show.dart';

abstract class UploadingState extends Equatable {
  final List<Show> selectedShows;
  const UploadingState(this.selectedShows);

  @override
  List<Object> get props => [selectedShows];
}

class LoadingUploadingState extends UploadingState {
  const LoadingUploadingState(super.selectedShows);
}

class LoadedUploadingState extends UploadingState {
  const LoadedUploadingState(super.selectedShows);
}
