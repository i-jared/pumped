import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/state/downloading/downloading_cubit.dart';
import 'package:pumped/state/downloading/downloading_state.dart';

class DownloadDisplay extends StatelessWidget {
  const DownloadDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => DownloadingCubit(),
        child: Builder(
          builder: (context) => _build(context),
        ));
  }

  Widget _build(BuildContext context) {
    final downloadingCubit = context.watch<DownloadingCubit>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Download Shows').mood(),
        ),
        body: downloadingCubit.state is LoadingDownloadingState
            ? _buildLoading()
            : const Text('Shows downloaded').alone());
  }

  Widget _buildLoading() => const CircularProgressIndicator().center();
}
