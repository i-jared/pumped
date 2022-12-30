import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:pumped/models/track.dart';
import 'package:pumped/widgets/painters/triangle_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/music/music_cubit.dart';
import 'package:pumped/state/music/music_state.dart';
import 'package:pumped/imports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TracksView extends StatefulWidget {
  const TracksView({super.key});
  @override
  State<TracksView> createState() => _TracksViewState();
}

class _TracksViewState extends State<TracksView> {
  late bool playerVisible = false;
  late bool playing = false;

  final green = const Color(0xffcdf564);
  final pink = const Color(0xfff037a5);
  final List<Map<String, Color>> colors = const [
    {'text': Color(0xff000000), 'background': Color(0xff4b917d)},
    {'text': Color(0xff000000), 'background': Color(0xfff037a5)},
    {'text': Color(0xff000000), 'background': Color(0xffcdf564)},
    {'text': Color(0xff000000), 'background': Color(0xffffffff)},
    {'text': Color(0xffffffff), 'background': Color(0xff000000)},
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final musicCubit = context.watch<MusicAuthCubit>();
    final musicState = musicCubit.state as LoadedTracksMusicState;
    final createShowCubit = context.watch<CreateShowCubit>();
    final createShowState = createShowCubit.state;
    return [
      ListView.builder(
          itemCount: musicState.tracks.length,
          itemBuilder: (context, i) {
            return _buildTrackItem(musicState.tracks[i], i, width);
          }),
      IgnorePointer(
              ignoring: !playerVisible,
              child: AnimatedOpacity(
                  opacity: playerVisible ? 0.8 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container()
                      .height(200)
                      .width(width - 20)
                      .decorated(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20))
                      .padding(horizontal: 10)))
          .positioned(bottom: 20),
      if (createShowState.track != null)
        // TODO move some of these widgets to their own things to reduce lines
        AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: playerVisible ? 1.0 : 0.0,
                child: _buildPlayer(width, musicCubit))
            .positioned(bottom: 20),
    ].toStack();
  }

  Widget _buildPlayer(double width, MusicAuthCubit musicCubit) {
    final createShowCubit = context.watch<CreateShowCubit>();
    final createShowState = createShowCubit.state;
    return [
      [
        AutoSizeText(createShowState.track!.name,
                maxLines: 1, style: TextStyle(color: green, fontSize: 30))
            .expanded(),
        Icon(Icons.save_outlined, color: green, size: 40).center().gestures(
            onTap: () {
          // emit new state and pop
          musicCubit.finishSongSelection();
        })
      ]
          .toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
          .padding(all: 15),
      const Spacer(),
      [
        Container()
            .height(5)
            .width(width - 150)
            .decorated(color: green, borderRadius: BorderRadius.circular(100))
            .alignment(Alignment.center),
        Container()
            .height(5)
            .width((width - 150) * createShowState.songStartRatio)
            .decorated(
                color: Colors.grey, borderRadius: BorderRadius.circular(100))
            .padding(left: 65)
            .alignment(Alignment.centerLeft),
        Container()
            .height(5)
            .width((width - 150) * (1 - createShowState.songEndRatio))
            .decorated(
                color: Colors.grey, borderRadius: BorderRadius.circular(100))
            .padding(right: 65)
            .alignment(Alignment.centerRight),
        CustomPaint(
          painter: TrianglePainter(color: Colors.yellow),
          child: const SizedBox(height: 40, width: 20),
        )
            .gestures(
                dragStartBehavior: DragStartBehavior.down,
                onHorizontalDragUpdate: (details) {
                  final double startRatio =
                      (details.globalPosition.dx - 75) / (width - 150);
                  createShowCubit.updateSong(songStartRatio: startRatio);
                  // move below to update song
                })
            .positioned(
                left: (width - 150) * createShowState.songStartRatio + 45),
        CustomPaint(
                painter: TrianglePainter(color: Colors.yellow, reverse: true),
                child: const SizedBox(height: 40, width: 20))
            .gestures(
                dragStartBehavior: DragStartBehavior.down,
                onHorizontalDragUpdate: (details) {
                  final double endRatio =
                      (details.globalPosition.dx - 75) / (width - 150);
                  createShowCubit.updateSong(songEndRatio: endRatio);
                  // move below to update song
                })
            .positioned(
                right:
                    (width - 150) * (1.0 - createShowState.songEndRatio) + 45),
      ].toStack().height(40).width(width),
      const SizedBox(height: 25),
      [
        Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 40, color: green)
            .gestures(onTap: () async {
          late bool result;
          if (playing) {
            createShowCubit.pausePlayback();
            result = true;
          } else {
            result = await createShowCubit.selectedSongPreview();
          }
          if (result) setState(() => playing = !playing);
        }),
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceEvenly),
      const Spacer(),
    ].toColumn().height(200).width(width - 20).padding(horizontal: 10);
  }

  Widget _buildTrackItem(Track track, int i, double width) {
    final createShowCubit = context.watch<CreateShowCubit>();
    final createShowState = createShowCubit.state;
    Map<String, Color> colorPair = colors[i % colors.length];
    return Container(
            color: colorPair['background'],
            child: [
              Row(children: [
                Container(
                  height: 150,
                  padding: const EdgeInsets.all(10),
                  width: 150,
                  child: CachedNetworkImage(
                      imageUrl: track.imageUrl, fit: BoxFit.cover),
                ),
                _buildTrackTitle(track, colorPair['text']!),
              ]),
              InkWell(
                  onTap: () async =>
                      await launchUrl(Uri.parse(track.spotifyLink!)),
                  child: Row(children: [
                    Image.asset(
                      'assets/spotify_icon.png',
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(width: 5),
                    const Text('PLAY ON SPOTIFY').textColor(Colors.black)
                  ])).positioned(bottom: 10, right: 10)
            ].toStack())
        .gestures(onTap: () {
      setState(() {
        if (createShowState.track == track && playerVisible) {
          playerVisible = false;
        } else {
          playerVisible = true;
        }
      });
      createShowCubit.updateSong(track: track);
    });
  }

  Widget _buildTrackTitle(Track track, Color color) {
    return AutoSizeText(track.name,
            textAlign: TextAlign.start,
            maxLines: 2,
            style: TextStyle(
                fontSize: 25, color: color, fontWeight: FontWeight.bold))
        .alignment(Alignment.centerLeft)
        .height(150)
        .expanded();
  }
}
