import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/create_show/create_show_state.dart';
import 'package:pumped/widgets/create_slide.dart';
import 'package:styled_widget/styled_widget.dart';

class CreateShowPage extends StatelessWidget {
  const CreateShowPage({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CreateShowCubit>();
    final loading = cubit.state is LoadingCreateShowState;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Show'),
          actions: [
            TextButton(
                onPressed: loading ? null : cubit.saveShow,
                child: const Text('Save')
                    .textColor(loading ? Colors.grey : Colors.white))
          ],
        ),
        body: SafeArea(child: _buildCarousel(context)));
  }

  Widget _buildCarousel(BuildContext context) {
    final cubit = context.watch<CreateShowCubit>();
    final state = cubit.state;
    // TODO: make it so you can long press to show remove slide button like ios app
    return LayoutBuilder(
      builder: (context, constraints) => CarouselSlider.builder(
        options: CarouselOptions(
            onPageChanged: (i, reason) => cubit.changeSlide(i),
            viewportFraction: 0.8,
            height: constraints.maxHeight,
            enableInfiniteScroll: false),
        itemCount: state.slides.length + 1,
        itemBuilder: (context, i, ri) {
          if (i < state.slides.length) {
            return CreateSlide(i: i);
          }
          return CreateSlide(i: i);
        },
      ),
    );
  }
}
