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
          brightness: Brightness.light,
          primarySwatch: MaterialColor(
            Colors.black.value,
            <int, Color>{
              50: Colors.black.withOpacity(0.1),
              100: Colors.black.withOpacity(0.2),
              200: Colors.black.withOpacity(0.3),
              300: Colors.black.withOpacity(0.4),
              400: Colors.black.withOpacity(0.5),
              500: Colors.black.withOpacity(0.6),
              600: Colors.black.withOpacity(0.7),
              700: Colors.black.withOpacity(0.8),
              800: Colors.black.withOpacity(0.9),
              900: Colors.black.withOpacity(1),
            },
          ),
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
      drawer: Drawer(
          width: 100,
          backgroundColor: Colors.black,
          child: Column(
            children: [
              DrawerHeader(child: const Text('🔥').fontSize(50)),
              IconButton(
                onPressed: () => null,
                icon: const Icon(Icons.alarm, color: Colors.white),
              ),
              const Divider(color: Colors.grey),
              IconButton(
                icon: const Icon(Icons.rocket, color: Colors.white),
                onPressed: () => null,
              ),
              const Divider(color: Colors.grey),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => null,
              ),
              const Divider(color: Colors.grey),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => null,
              ),
            ],
          )),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title:
                const Text('💪 Pumped').bold().italic().textColor(Colors.white),
            actions: [
              if (slidesCubit.state is EditingShowsState)
                TextButton(
                    onPressed: slidesCubit.finishEdit,
                    child: const Text('Done').textColor(Colors.white))
            ],
          ),
          slidesCubit.state is LoadingShowsState
              ? SliverFillRemaining(
                  child: const CircularProgressIndicator().center())
              : _buildGrid(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.black,
        onPressed: () => goToCreateShow(context),
        tooltip: 'Create Slide',
        child: const Icon(Icons.add, size: 80),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final cubit = context.watch<ShowsCubit>();
    final state = cubit.state as LoadedShowsState;
    if (state.shows.isEmpty) {
      return SliverFillRemaining(
          child: const Text('Add a show.\nGet pumped.').alone());
    }
    return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        delegate: SliverChildBuilderDelegate(childCount: state.shows.length,
            (context, i) {
          final show = state.shows[i];
          return _buildGridItem(context, show, cubit);
        }));
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
            // borderRadius: BorderRadius.circular(20),
            // boxShadow: kElevationToShadow[3],
          )
          // .padding(all: 15)
          .gestures(
              onLongPress: cubit.edit,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ViewShow(show)))),
      Positioned(
        top: 60,
        left: 10,
        child: IgnorePointer(
          ignoring: cubit.state is! EditingShowsState,
          child: GestureDetector(
            child: const Icon(Icons.clear, size: 30),
            onTap: () => cubit.removeShow(show),
          )
              .padding(all: 5)
              .decorated(
                  color: Colors.white, borderRadius: BorderRadius.circular(30))
              .opacity(
                  animate: true, cubit.state is EditingShowsState ? 1.0 : 0)
              .animate(const Duration(milliseconds: 400), Curves.linear),
        ),
      ),
      Positioned(
        top: 10,
        left: 10,
        child: IgnorePointer(
          ignoring: cubit.state is! EditingShowsState,
          child: GestureDetector(
            child: const Icon(Icons.edit, size: 30),
            onTap: () => goToCreateShow(context, show),
          )
              .padding(all: 5)
              .decorated(
                  color: Colors.white, borderRadius: BorderRadius.circular(30))
              .opacity(
                  animate: true, cubit.state is EditingShowsState ? 1.0 : 0)
              .animate(const Duration(milliseconds: 400), Curves.linear),
        ),
      )
    ].toStack();
  }
}
