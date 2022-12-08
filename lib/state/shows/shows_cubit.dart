import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/state/shows/shows_repo.dart';
import 'package:pumped/state/shows/shows_state.dart';

class ShowsCubit extends Cubit<ShowsState> {
  final ShowsRepo showsRepo;
  ShowsCubit(this.showsRepo) : super(LoadingShowsState()) {
    loadShows();
  }

  Future<void> loadShows() async {
    final shows = await showsRepo.loadShows();
    emit(LoadedShowsState(shows));
  }

  Future<void> createShow() async {}

  Future<void> saveShow(Show newShow) async {
    final savedShows =
        (state is LoadedShowsState) ? (state as LoadedShowsState).shows : [];
    emit(LoadingShowsState());
    await showsRepo.saveShow(newShow);
    emit(LoadedShowsState([newShow, ...savedShows]));
  }
}
