import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/track.dart';
import 'package:pumped/pages/create_show.dart';
import 'package:pumped/pages/view_show.dart';
import 'package:pumped/state/music/music_cubit.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/shows/shows_cubit.dart';
import 'package:pumped/state/shows/shows_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Hive.initFlutter();
  Hive.registerAdapter(ShowAdapter());
  Hive.registerAdapter(TextSlideAdapter());
  Hive.registerAdapter(ImageSlideAdapter());
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(FileAdapter());
  Hive.registerAdapter(TrackAdapter());
  await Hive.openBox(hiveBoxName);
  init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ShowsCubit>.value(value: getIt<ShowsCubit>()),
        BlocProvider<MusicAuthCubit>.value(value: getIt<MusicAuthCubit>()),
      ],
      child: MaterialApp(
        title: 'Pumped',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final slidesCubit = context.watch<ShowsCubit>();
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (slidesCubit.state is EditingShowsState)
            TextButton(
                onPressed: slidesCubit.finishEdit,
                child: const Text('Done').textColor(Colors.white))
        ],
        title: const Text('Pumped'),
      ),
      drawer: Drawer(
          child: Column(
        children: [
          DrawerHeader(child: Image.asset('assets/pumped_logo.webp')),
          ListTile(
              leading: const Icon(Icons.alarm),
              title:
                  const Text('Upcoming: Notifications').textColor(Colors.grey)),
          ListTile(
              leading: const Icon(Icons.rocket),
              title: const Text('Upcoming: Share').textColor(Colors.grey)),
          ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Upcoming: Search').textColor(Colors.grey)),
          const Divider(),
          ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Upcoming: Settings').textColor(Colors.grey)),
        ],
      )),
      body: slidesCubit.state is LoadingShowsState
          ? const CircularProgressIndicator().center()
          : _buildGrid(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToCreateShow(context),
        tooltip: 'Create Slide',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final cubit = context.watch<ShowsCubit>();
    final state = cubit.state as LoadedShowsState;
    final width = MediaQuery.of(context).size.width;
    if (state.shows.isEmpty) {
      return const Text('Add a new show to get pumped!').center();
    }
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: state.shows.length,
        itemBuilder: (context, i) {
          final show = state.shows[i];
          return _buildGridItem(context, show, cubit);
        });
  }

  void goToCreateShow(BuildContext context, [Show? show]) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BlocProvider<CreateShowCubit>(
            create: (context) => CreateShowCubit(show),
            child: CreateShowPage(show: show))));
  }

  Widget _buildGridItem(BuildContext context, Show show, ShowsCubit cubit) {
    return [
      (show.titleSlide is TextSlide
              ? AutoSizeText(
                  (show.titleSlide as TextSlide).text,
                  style: TextStyle(
                      fontSize: 40,
                      color: (show.titleSlide as TextSlide).textColor),
                  textAlign: TextAlign.center,
                ).center()
              : Container())
          .decorated(
              color: show.titleSlide is TextSlide
                  ? (show.titleSlide as TextSlide).backgroundColor
                  : Colors.white,
              image: show.titleSlide is ImageSlide
                  ? (show.titleSlide as ImageSlide).image == null
                      ? null
                      : DecorationImage(
                          image:
                              FileImage((show.titleSlide as ImageSlide).image!),
                          fit: BoxFit.cover)
                  : null,
              borderRadius: BorderRadius.circular(20),
              boxShadow: kElevationToShadow[8])
          .padding(all: 15)
          .gestures(
              onLongPress: cubit.edit,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ViewShow(show)))),
      if (cubit.state is EditingShowsState)
        Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.clear),
              iconSize: 30,
              onPressed: () => cubit.removeShow(show),
            )),
      if (cubit.state is EditingShowsState)
        Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.edit),
              iconSize: 30,
              onPressed: () => goToCreateShow(context, show),
            ))
    ].toStack();
  }
}
