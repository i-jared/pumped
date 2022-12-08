import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/slide.dart';

class ViewShow extends StatelessWidget {
  final Show show;
  const ViewShow(this.show, {super.key});
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    logger.wtf(height);
    logger.wtf(width);
    return Scaffold(
      body: CarouselSlider.builder(
          options: CarouselOptions(
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            height: height,
          ),
          itemCount: show.slides.length,
          itemBuilder: (context, i, ri) {
            final slide = show.slides[i];
            late Widget child;
            switch (slide.runtimeType) {
              case (TextSlide):
                slide as TextSlide;
                child = AutoSizeText(
                  slide.text,
                  style: TextStyle(fontSize: 40, color: slide.textColor),
                  textAlign: TextAlign.center,
                )
                    .center()
                    .height(height)
                    .width(width)
                    .decorated(color: slide.backgroundColor);
                break;
              case (ImageSlide):
                slide as ImageSlide;
                child = Container().height(height).width(width).decorated(
                    image: DecorationImage(
                        image: FileImage(slide.image!), fit: BoxFit.cover));
                break;
              default:
                child = Container();
            }
            return child;
          }),
    );
  }
}
