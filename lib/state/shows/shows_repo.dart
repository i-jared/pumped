import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pumped/constants.dart';
import 'package:pumped/models/show.dart';

class ShowsRepo {
  final Box _box;
  final String showsKey = 'shows';
  ShowsRepo() : _box = Hive.box(hiveBoxName);

  Future<List<Show>> loadShows() async {
    List<Show>? shows = List<Show>.from(_box.get(showsKey) ?? []);
    return shows;
  }

  Future<Show> saveShow(Show show) async {
    List<Show>? optShows = List<Show>.from(_box.get(showsKey) ?? []);
    List<Show> shows = optShows.whereNotNull().toList();
    int i = shows.indexWhere((s) => s.uid == show.uid);
    if (i >= 0) shows.removeAt(i);
    await _box.put(showsKey, [...optShows, show]);
    return show;
  }
}
