import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/playlist.dart';
import 'package:pumped/state/music/music_cubit.dart';
import 'package:pumped/state/music/music_state.dart';
import 'package:pumped/widgets/music_selection/tracks_view.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  @override
  void initState() {
    super.initState();
    getIt<MusicAuthCubit>().loadPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    final musicCubit = context.watch<MusicAuthCubit>();
    final musicState = musicCubit.state;

    return WillPopScope(
      onWillPop: () async {
        if (musicState is LoadedTracksMusicState) {
          musicCubit.goToPlaylists();
          return false;
        }
        if (musicState is LoadedPlaylistsMusicState) return true;
        return true;
      },
      child: BlocListener<MusicAuthCubit, MusicAuthState>(
        listener: (context, state) {
          if (state is LoggedOutMusicState ||
              state is FinishedTracksMusicState) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(),
          body: musicState is LoadingMusicState
              ? _buildLoadingIndicator()
              : musicState is ErrorMusicState
                  ? _buildErrorIndicator()
                  : musicState is LoadedTracksMusicState
                      ? const TracksView()
                      : musicState is LoadedPlaylistsMusicState
                          ? _buildPlaylists()
                          : _buildDefaultError(),
        ),
      ),
    );
  }

  Widget _buildPlaylists() {
    final musicState =
        context.watch<MusicAuthCubit>().state as LoadedPlaylistsMusicState;
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: musicState.playlists.length,
      itemBuilder: (context, i) {
        return _buildPlaylistItem(musicState.playlists[i]);
      },
    );
  }

  Widget _buildDefaultError() {
    return const Text('Something went wrong...').alone();
  }

  Widget _buildErrorIndicator() {
    final musicState = context.watch<MusicAuthCubit>().state as ErrorMusicState;
    return Text(musicState.message).alone();
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator().center();
  }

  Widget _buildPlaylistItem(Playlist playlist) {
    final musicCubit = context.watch<MusicAuthCubit>();
    return Column(
      children: [
        if (playlist.imageUrl == null) ...[
          const Text('N/A')
              .textColor(Colors.white)
              .backgroundColor(Colors.black)
              .padding(all: 5)
              .gestures(onTap: () => musicCubit.loadPlaylistTracks(playlist)),
        ],
        if (playlist.imageUrl != null) ...[
          Container()
              .backgroundImage(DecorationImage(
                  image: CachedNetworkImageProvider(playlist.imageUrl!)))
              .padding(all: 5)
              .gestures(onTap: () => musicCubit.loadPlaylistTracks(playlist))
              .expanded(),
        ],
        [
          const Text('PLAY ON SPOTIFY').fontSize(10),
          Image.asset('assets/spotify_icon.png', height: 20, width: 20)
        ]
            .toRow(mainAxisAlignment: MainAxisAlignment.center)
            .gestures(onTap: () => launchUrlString(playlist.spotifyLink!)),
      ],
    );
  }
}
