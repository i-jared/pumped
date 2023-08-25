import 'package:equatable/equatable.dart';
import 'package:pumped/models/show.dart';

abstract class DownloadingState extends Equatable {
  final List<Show> selectedShows;
  final List<Show> availableShows;
  const DownloadingState(this.availableShows, this.selectedShows);

  @override
  List<Object> get props => [selectedShows];
}

class LoadingDownloadingState extends DownloadingState {
  const LoadingDownloadingState(super.availableShows, super.selectedShows);
}

class LoadedDownloadingState extends DownloadingState {
  const LoadedDownloadingState(super.availableShows, super.selectedShows);
}
