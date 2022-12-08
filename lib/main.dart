import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pumped/constants.dart';
import 'package:pumped/initializer.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/pages/create_show.dart';
import 'package:pumped/pages/view_show.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/shows/shows_cubit.dart';
import 'package:pumped/state/shows/shows_state.dart';
import 'package:styled_widget/styled_widget.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ShowAdapter());
  Hive.registerAdapter(TextSlideAdapter());
  Hive.registerAdapter(ImageSlideAdapter());
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(FileAdapter());
  await Hive.openBox(hiveBoxName);
  init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShowsCubit>.value(
      value: getIt<ShowsCubit>(),
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
    final slidesCubit = BlocProvider.of<ShowsCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pumped'),
      ),
      drawer: Drawer(
          child: Column(
        children: [DrawerHeader(child: Image.asset('assets/pumped_logo.webp'))],
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
    final slidesCubit = context.watch<ShowsCubit>();
    final state = slidesCubit.state as LoadedShowsState;
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: state.shows.length,
        itemBuilder: (context, i) {
          final show = state.shows[i];
          return Text(show.title)
              .decorated(
                  color: Colors.white,
                  boxShadow: kElevationToShadow[8],
                  borderRadius: BorderRadius.circular(15))
              .padding(all: 15)
              .gestures(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ViewShow(show))));
        });
  }

  void goToCreateShow(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BlocProvider<CreateShowCubit>(
            create: (context) => CreateShowCubit(),
            child: const CreateShowPage())));
  }
}
