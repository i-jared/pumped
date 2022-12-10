import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/playlist.dart';
import 'package:pumped/models/track.dart';
import 'package:pumped/state/auth/auth_cubit.dart';
import 'package:pumped/state/auth/auth_state.dart';
import 'package:pumped/widgets/painters/triangle_painter.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class MusicSelector extends StatefulWidget {
  const MusicSelector({super.key});

  @override
  State<StatefulWidget> createState() => _MusicSelectorState();
}

class _MusicSelectorState extends State<MusicSelector> {
  final green = const Color(0xffcdf564);
  final pink = const Color(0xfff037a5);
  final List<Map<String, Color>> colors = const [
    {'text': Color(0xff000000), 'background': Color(0xff4b917d)},
    {'text': Color(0xff000000), 'background': Color(0xfff037a5)},
    {'text': Color(0xff000000), 'background': Color(0xffcdf564)},
    {'text': Color(0xff000000), 'background': Color(0xffffffff)},
    {'text': Color(0xffffffff), 'background': Color(0xff000000)},
  ];
  late bool playerVisible = false;
  late bool playing = false;
  late double leftPlayerPosition;
  late double rightPlayerPosition;
  Track? selectedTrack;
  @override
  void initState() {
    super.initState();
    getIt<AuthCubit>().loadPlaylists();
    leftPlayerPosition = 0.0;
    rightPlayerPosition = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();
    final authState = authCubit.state;

    return WillPopScope(
      onWillPop: () async {
        if (authState is LoadedTracksAuthState) {
          authCubit.goToPlaylists();
          return false;
        }
        if (authState is LoadedPlaylistsAuthState) return true;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: authState is LoadingAuthState
            ? _buildLoadingIndicator()
            : authState is ErrorAuthState
                ? _buildErrorIndicator()
                : authState is LoadedTracksAuthState
                    ? _buildTracks()
                    : authState is LoadedPlaylistsAuthState
                        ? _buildPlaylists()
                        : _buildDefaultError(),
      ),
    );
  }

  Widget _buildTracks() {
    final double width = MediaQuery.of(context).size.width;
    final authState = context.watch<AuthCubit>().state as LoadedTracksAuthState;
    return [
      ListView.builder(
          itemCount: authState.tracks.length,
          itemBuilder: (context, i) {
            return _buildTrackItem(authState.tracks[i], i, width);
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
      if (selectedTrack != null)
        AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: playerVisible ? 1.0 : 0.0,
                child: [
                  [
                    AutoSizeText(selectedTrack!.name,
                            maxLines: 1,
                            style: TextStyle(color: green, fontSize: 30))
                        .expanded(),
                    Icon(Icons.save_outlined, color: green, size: 40)
                        .center()
                        .gestures(onTap: () => null)
                  ]
                      .toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
                      .padding(all: 15),
                  const Spacer(),
                  [
                    Container()
                        .height(5)
                        .width(width - 150)
                        .decorated(
                            color: green,
                            borderRadius: BorderRadius.circular(100))
                        .alignment(Alignment.center),
                    Container()
                        .height(5)
                        .width((width - 150) * leftPlayerPosition)
                        .decorated(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(100))
                        .padding(left: 65)
                        .alignment(Alignment.centerLeft),
                    Container()
                        .height(5)
                        .width((width - 150) * (1 - rightPlayerPosition))
                        .decorated(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(100))
                        .padding(right: 65)
                        .alignment(Alignment.centerRight),
                    CustomPaint(
                      painter: TrianglePainter(color: Colors.yellow),
                      child: const SizedBox(height: 40, width: 20),
                    ).gestures(onHorizontalDragUpdate: (details) {
                      setState(() => leftPlayerPosition = max(
                          0.0,
                          min((details.globalPosition.dx - 75) / (width - 150),
                              rightPlayerPosition)));
                    }).positioned(
                        left: (width - 150) * leftPlayerPosition + 45),
                    CustomPaint(
                            painter: TrianglePainter(
                                color: Colors.yellow, reverse: true),
                            child: const SizedBox(height: 40, width: 20))
                        .gestures(onHorizontalDragUpdate: (details) {
                      setState(() => rightPlayerPosition = min(
                          1.0,
                          max((details.globalPosition.dx - 75) / (width - 150),
                              leftPlayerPosition)));
                    }).positioned(
                            right: (width - 150) * (1.0 - rightPlayerPosition) +
                                45),
                  ].toStack().height(40).width(width),
                  const SizedBox(height: 25),
                  [
                    Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 40,
                            color: green)
                        .gestures(onTap: () async {
                      if (playing) {
                        await SpotifySdk.resume();
                      } else {
                        await SpotifySdk.play(spotifyUri: selectedTrack!.uri);
                        await SpotifySdk.seekTo(
                            positionedMilliseconds: (leftPlayerPosition *
                                    selectedTrack!.durationMils)
                                .ceil());
                      }
                      setState(() => playing = !playing);
                    }),
                  ].toRow(mainAxisAlignment: MainAxisAlignment.spaceEvenly),
                  const Spacer(),
                ]
                    .toColumn()
                    .height(200)
                    .width(width - 20)
                    .padding(horizontal: 10))
            .positioned(bottom: 20),
    ].toStack();
  }

  Widget _buildPlaylists() {
    final authState =
        context.watch<AuthCubit>().state as LoadedPlaylistsAuthState;
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: authState.playlists.length,
      itemBuilder: (context, i) {
        return _buildPlaylistItem(authState.playlists[i]);
      },
    );
  }

  Widget _buildDefaultError() {
    return const Text('Something went wrong...').center();
  }

  Widget _buildErrorIndicator() {
    final authState = context.watch<AuthCubit>().state as ErrorAuthState;
    return Text(authState.message).center();
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator().center();
  }

  Widget _buildPlaylistItem(Playlist playlist) {
    final authCubit = context.watch<AuthCubit>();
    return Container()
        .backgroundImage(DecorationImage(
            image: CachedNetworkImageProvider(playlist.imageUrl)))
        .padding(all: 5)
        .gestures(onTap: () => authCubit.loadPlaylistTracks(playlist));
  }

  Widget _buildTrackItem(Track track, int i, double width) {
    Map<String, Color> colorPair = colors[i % colors.length];
    return Container(
            padding: i == 0 ? const EdgeInsets.only(top: 200 * 0.2) : null,
            color: i == 0 ? colorPair['background'] : null,
            child: [
              Container(
                  color: colorPair['background'],
                  height: 200 * 0.8,
                  width: width),
              Align(
                  heightFactor: 0.7,
                  child: Row(children: [
                    if (i.isEven) _buildTrackTitle(track, colorPair['text']!),
                    Container(
                      height: 200,
                      padding: EdgeInsets.all(10),
                      width: 200,
                      child: CachedNetworkImage(
                          imageUrl: track.imageUrl, fit: BoxFit.cover),
                    ),
                    if (i.isOdd) _buildTrackTitle(track, colorPair['text']!),
                  ])),
            ].toStack())
        .gestures(onTap: () {
      setState(() {
        if (selectedTrack == track && playerVisible) {
          playerVisible = false;
        } else {
          playerVisible = true;
        }
        selectedTrack = track;
      });
    });
  }

  Widget _buildTrackTitle(Track track, Color color) {
    return AutoSizeText(track.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
                fontSize: 25, color: color, fontWeight: FontWeight.bold))
        .expanded();
  }
}
