import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/state/shows/shows_cubit.dart';

class ViewShow extends StatefulWidget {
  final Show show;
  const ViewShow(this.show, {super.key});
  @override
  State<StatefulWidget> createState() => _ViewShowState();
}

class _ViewShowState extends State<ViewShow> {
  late CarouselController _controller;
  @override
  void didChangeDependencies() {
    widget.show.slides.forEach(precache);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    final showsCubit = getIt<ShowsCubit>();
    showsCubit.playShowTune(widget.show);
    _controller = CarouselController();
  }

  @override
  void dispose() {
    final showsCubit = getIt<ShowsCubit>();
    showsCubit.quitPlayback(widget.show);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: CarouselSlider.builder(
            carouselController: _controller,
            options: CarouselOptions(
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              height: height,
            ),
            itemCount: widget.show.slides.length,
            itemBuilder: (context, i, ri) {
              final slide = widget.show.slides[i];
              late Widget child;
              switch (slide.runtimeType) {
                case (TextSlide):
                  slide as TextSlide;
                  child = AutoSizeText(
                    presetFontSizes: const [80, 60, 40, 20],
                    slide.text,
                    style: TextStyle(fontSize: 80, color: slide.textColor),
                    textAlign: TextAlign.center,
                  )
                      .center()
                      .height(height)
                      .width(width)
                      .padding(vertical: 150)
                      .decorated(color: slide.backgroundColor);
                  break;
                case (ImageSlide):
                  slide as ImageSlide;
                  child = Container().height(height).width(width).decorated(
                      image: slide.image == null
                          ? null
                          : DecorationImage(
                              image: FileImage(slide.image!),
                              fit: BoxFit.cover));
                  break;
                default:
                  child = Container();
              }
              return Stack(children: [
                child,
                Row(
                  children: [
                    Container()
                        .backgroundColor(Colors.transparent)
                        .gestures(
                            onTap: () => i > 0
                                ? _controller.previousPage(
                                    duration: const Duration(milliseconds: 100))
                                : null)
                        .expanded(),
                    Container()
                        .backgroundColor(Colors.transparent)
                        .gestures(
                            onTap: () => i == widget.show.slides.length - 1
                                ? null
                                : _controller.nextPage(
                                    duration:
                                        const Duration(milliseconds: 100)))
                        .expanded(),
                  ],
                ),
              ]);
            }));
  }

  void precache(slide) {
    if (slide is ImageSlide && slide.image != null) {
      precacheImage(FileImage(slide.image!), context);
    }
  }
}
