import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/state/uploading/uploading_state.dart';

class UploadingCubit extends Cubit<UploadingState> {
  late List<Show> initialShows;
  UploadingCubit() : super(const LoadingUploadingState([])) {
    init();
  }

  void init() async {
    // TODO: get uploaded shows from firestore
    initialShows = [];
    emit(LoadedUploadingState(initialShows));
  }

  void selectShow(Show show) {
    var updatedShowList = List<Show>.from(state.selectedShows);
    if (updatedShowList.contains(show)) {
      if (initialShows.contains(show)) {
        // todo: notfiy user that they can't remove this show
        return;
      }
      updatedShowList.remove(show);
    } else {
      updatedShowList.add(show);
    }
    emit(LoadedUploadingState(updatedShowList));
  }

  Future<void> upload() async {
    // get list of shows to upload
    var newShows = state.selectedShows
        .where((show) => !initialShows.contains(show))
        .toList();
    // upload
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collections = firestore.collection('collections');
    for (var show in newShows) {
      var storageRef = FirebaseStorage.instance.ref();
      var showRef = storageRef.child(show.uid);
      // upload images, get urls, put them in the object below.
      Map<String, dynamic> urls = {'slides': {}, 'titleSlide': null};
      if (show.titleSlide is ImageSlide) {
        // upload image
        var image = (show.titleSlide as ImageSlide).image;
        var path = image?.path;
        if (path != null && image != null) {
          var titleRef = showRef.child('titleSlide.${path.split('.').last}');
          await titleRef.putFile(image);
          // add url to urls
          urls['titleSlide'] = await titleRef.getDownloadURL();
        }
      }
      for (var slide in show.slides) {
        if (slide is ImageSlide) {
          var image = slide.image;
          var path = image?.path;
          if (path != null && image != null) {
            var slideRef = showRef
                .child('${show.slides.indexOf(slide)}.${path.split('.').last}');
            await slideRef.putFile(image);
            // add url to urls
            urls['slides']['${show.slides.indexOf(slide)}'] =
                await slideRef.getDownloadURL();
          }
        }
      }
      await collections.add({
        'slides': {
          ...show.slides.mapIndexed((index, slide) => {
                'imageUrl': urls['slides']![index],
                'text': slide is TextSlide ? slide.text : null,
                'textColor':
                    slide is TextSlide ? slide.textColor.toString() : null,
                'backgroundColor': slide is TextSlide
                    ? slide.backgroundColor.toString()
                    : null,
              })
        },
        'titleSlide': {
          'imageUrl': urls['titleSlide'],
          'text': show.titleSlide is TextSlide
              ? (show.titleSlide as TextSlide).text
              : null,
          'textColor': show.titleSlide is TextSlide
              ? (show.titleSlide as TextSlide).textColor.toString()
              : null,
          'backgroundColor': show.titleSlide is TextSlide
              ? (show.titleSlide as TextSlide).backgroundColor.toString()
              : null,
        },
        'track': {
          'artist': show.track?.artist,
          'durationMils': show.track?.durationMils,
          'imageUrl': show.track?.imageUrl,
          'name': show.track?.name,
          'spotifyLink': show.track?.spotifyLink,
          'uri': show.track?.uri,
        },
        'uid': show.uid,
        'songStartRatio': show.songStartRatio,
        'songEndRatio': show.songEndRatio,
      });
    }
  }
}
