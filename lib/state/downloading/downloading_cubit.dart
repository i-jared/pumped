import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/state/downloading/downloading_state.dart';
import 'package:pumped/state/shows/shows_cubit.dart';

class DownloadingCubit extends Cubit<DownloadingState> {
  DownloadingCubit() : super(const LoadingDownloadingState([], [])) {
    init();
  }

  void init() async {
    var shows = <Show>[];

    logger.wtf('init');
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference showsref = firestore.collection('shows');
    var showsMaps = await showsref.get();
    for (var snapshot in showsMaps.docs) {
      var showMap = snapshot.data() as Map<String, dynamic>;
      logger.wtf(showMap);
      var show = await Show.fromFirestore(showMap);
      await getIt<ShowsCubit>().saveShow(show);
      shows.add(show);
    }
    logger.wtf("end");
    // todo save it in hive. i do that, right?
    emit(LoadedDownloadingState(shows, const []));
  }

  void selectShow(Show show) {
    var updatedShowList = List<Show>.from(state.selectedShows);
    if (updatedShowList.contains(show)) {
      updatedShowList.remove(show);
    } else {
      updatedShowList.add(show);
    }
    emit(LoadedDownloadingState(state.availableShows, updatedShowList));
  }

  Future<void> download() async {
    emit(LoadingDownloadingState(state.availableShows, state.selectedShows));
    // download stuff
    emit(LoadedDownloadingState(state.availableShows, const []));
  }
}
