import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/widgets/create_show/create_show_app_bar.dart';
import 'package:pumped/widgets/create_slide.dart';
import 'package:styled_widget/styled_widget.dart';

class CreateShowPage extends StatefulWidget {
  final Show? show;
  const CreateShowPage({this.show, super.key});
  @override
  State<StatefulWidget> createState() => _CreateShowPageState();
}

class _CreateShowPageState extends State<CreateShowPage> {
  late ScrollController _scrollController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    // initialize text controller
    if (widget.show != null && widget.show!.titleSlide is TextSlide) {
      _textController = TextEditingController(
          text: (widget.show!.titleSlide as TextSlide).text);
    } else {
      _textController = TextEditingController(text: 'Untitled');
    }
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            resizeToAvoidBottomInset: true,
            body: NestedScrollView(
                physics: const ClampingScrollPhysics(),
                controller: _scrollController,
                headerSliverBuilder: (context, isScrolled) => [
                      CreateShowAppBar(
                          scrollExtent: _scrollController.hasClients
                              ? _scrollController.offset /
                                  _scrollController.position.maxScrollExtent
                              : 0.0,
                          textController: _textController,
                          tapHeader: tapHeader)
                    ],
                body: _buildCarousel(context)))
        .gestures(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Widget _buildCarousel(BuildContext context) {
    final cubit = context.watch<CreateShowCubit>();
    final state = cubit.state;
    return LayoutBuilder(
      builder: (context, constraints) => CarouselSlider.builder(
        options: CarouselOptions(
            onPageChanged: (i, reason) => cubit.changeSlide(i),
            viewportFraction: 0.8,
            height: constraints.maxHeight,
            enableInfiniteScroll: false),
        itemCount: state.slides.length + 1,
        itemBuilder: (context, i, ri) {
          return CreateSlide(
              i: i, slide: i >= state.slides.length ? null : state.slides[i]);
        },
      ),
    );
  }

  void tapHeader() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
          _scrollController.offset <
                  _scrollController.position.maxScrollExtent / 2
              ? _scrollController.position.maxScrollExtent
              : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceInOut);
    }
  }
}
