import 'package:equatable/equatable.dart';
import 'package:pumped/models/show.dart';

class ShowsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingShowsState extends ShowsState {}

class LoadedShowsState extends ShowsState {
  final List<Show> shows;
  LoadedShowsState(this.shows);

  @override
  List<Object?> get props => [shows];
}

class EditingShowsState extends LoadedShowsState {
  EditingShowsState(List<Show> shows) : super(shows);
}
