import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/pages/music_selector.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/create_show/create_show_state.dart';
import 'package:pumped/widgets/create_show/title_modal.dart';

class CreateShowAppBar extends StatefulWidget {
  final double scrollExtent;
  final TextEditingController textController;
  final VoidCallback tapHeader;
  const CreateShowAppBar(
      {required this.scrollExtent,
      required this.textController,
      required this.tapHeader,
      super.key});

  @override
  State<StatefulWidget> createState() => _CreateShowAppBarState();
}

class _CreateShowAppBarState extends State<CreateShowAppBar>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late Animation<double> animation2;
  late AnimationController controller;
  late AnimationController controller2;
  late bool edit;
  @override
  void initState() {
    super.initState();
    edit = false;
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    controller2 = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: pi).animate(controller)
      ..addListener(() => setState(() {}));
    animation2 = Tween<double>(begin: 0, end: pi).animate(controller2)
      ..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CreateShowCubit>();
    final loading = cubit.state is LoadingCreateShowState;
    Slide ts = cubit.state.titleSlide;
    bool isText = ts.runtimeType == TextSlide;
    TextSlide? textSlide = isText ? ts as TextSlide : null;
    ImageSlide? imageSlide = isText ? null : ts as ImageSlide;
    final imageRad = animation.value - pi / 6;
    final textRad = animation.value - 4 * pi / 7;
    final bgColRad = animation2.value - pi / 6;
    final textColRad = animation2.value - 4 * pi / 7;
    final title = isText
        ? IntrinsicWidth(
            child: TextField(
              onChanged: (val) => cubit.updateSlide(-1, text: val),
              toolbarOptions: const ToolbarOptions(
                  copy: false, selectAll: false, paste: false, cut: false),
              onTap: () {
                widget.scrollExtent == 1.0 ? widget.tapHeader() : null;
              },
              controller: widget.textController,
              textAlign: TextAlign.center,
              style: TextStyle(color: textSlide!.textColor, fontSize: 25),
              cursorColor: textSlide.textColor,
              decoration: InputDecoration(
                  hintText: 'Enter your title',
                  hintStyle: TextStyle(color: textSlide.textColor),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero),
              scrollPadding: EdgeInsets.zero,
            ),
          ).padding(horizontal: 10)
        : const SizedBox.shrink();

    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverAppBar(
          pinned: true,
          expandedHeight: 350,
          leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.chevron_left,
                      size: 40, color: Colors.black))
              .decorated(
                  color: Colors.white, borderRadius: BorderRadius.circular(50))
              .padding(all: 7),
          flexibleSpace: Container(
              decoration: BoxDecoration(
                image: !isText
                    ? imageSlide!.image != null
                        ? DecorationImage(
                            image: FileImage(imageSlide.image!),
                            fit: BoxFit.cover)
                        : null
                    : null,
                color: isText ? textSlide!.backgroundColor : null,
              ),
              child: FlexibleSpaceBar(
                centerTitle: true,
                expandedTitleScale: 2.0,
                title: Stack(
                  children: [
                    Align(alignment: Alignment.bottomCenter, child: title),
                    Positioned(
                        right: 5,
                        bottom: 60,
                        child: Opacity(
                          opacity: 1 - widget.scrollExtent,
                          child: Row(
                            children: [
                              Text(cubit.state.track?.name ?? '')
                                  .textColor(cubit.state.titleSlide is TextSlide
                                      ? (cubit.state.titleSlide as TextSlide)
                                          .textColor
                                      : Colors.black)
                                  .fontWeight(FontWeight.w300),
                              const Icon(Icons.music_note_outlined, size: 25)
                                  .padding(all: 2)
                                  .decorated(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100))
                                  .gestures(
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BlocProvider.value(
                                                      value: cubit,
                                                      child:
                                                          const MusicSelector())))),
                            ],
                          ),
                        )),
                    Stack(
                      children: [
                        AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.decelerate,
                            right: edit ? -20 : 5,
                            bottom: edit ? -0 : 25,
                            child: Opacity(
                              opacity: 1 - widget.scrollExtent,
                              child: const Icon(Icons.edit_outlined, size: 25)
                                  .padding(all: 2)
                                  .height(edit ? 100 : 29, animate: true)
                                  .width(edit ? 100 : 29, animate: true)
                                  .animate(const Duration(milliseconds: 300),
                                      Curves.decelerate)
                                  .decorated(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100))
                                  .gestures(onTap: () async {
                                if (!edit) {
                                  setState(() => edit = true);
                                  Future.delayed(
                                      const Duration(
                                        milliseconds: 200,
                                      ), () {
                                    controller.forward();
                                  });
                                } else {
                                  controller.reverse();
                                  controller2.reverse();
                                  Future.delayed(
                                      const Duration(
                                        milliseconds: 200,
                                      ), () {
                                    setState(() => edit = false);
                                  });
                                }
                              }),
                              // onTap: () => _pushTitleModal(context, cubit)),
                            )),
                        Positioned(
                          bottom: sin(bgColRad) * 40 + 30,
                          right: bgColRad * 90 / pi - 30,
                          child: Transform.rotate(
                              angle: -bgColRad + pi / 2,
                              child: GestureDetector(
                                onTap: () {
                                  controller.reverse();
                                  Future.delayed(
                                      const Duration(milliseconds: 300),
                                      () => setState(() {
                                            edit = false;
                                          }));
                                  cubit.updateTitle(ImageSlide());
                                  cubit.pickImage(-1);
                                },
                                child: [
                                  Container().height(20).width(20).decorated(
                                      color:
                                          (cubit.state.titleSlide is TextSlide)
                                              ? (cubit.state.titleSlide
                                                      as TextSlide)
                                                  .backgroundColor
                                              : Colors.black,
                                      border: Border.all(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(15)),
                                  const Text('BG')
                                      .bold()
                                      .fontSize(12)
                                      .textColor(Colors.black),
                                ]
                                    .toColumn(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center)
                                    .gestures(
                                        onTap: () => showColorPicker(
                                            context,
                                            cubit.state.titleSlide,
                                            (val) => cubit.updateSlide(-1,
                                                backgroundColor: val))),
                              )),
                        ),
                        Positioned(
                          bottom: sin(textColRad) * 40 + 25,
                          right: textColRad * 90 / pi - 30,
                          child: Transform.rotate(
                              angle: -textColRad + pi / 2,
                              child: GestureDetector(
                                onTap: () {},
                                child: [
                                  Container().height(20).width(20).decorated(
                                      color:
                                          (cubit.state.titleSlide is TextSlide)
                                              ? (cubit.state.titleSlide
                                                      as TextSlide)
                                                  .textColor
                                              : Colors.black,
                                      border: Border.all(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(15)),
                                  const Text('TXT')
                                      .bold()
                                      .fontSize(12)
                                      .textColor(Colors.black),
                                ]
                                    .toColumn(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center)
                                    .gestures(
                                        onTap: () => showColorPicker(
                                            context,
                                            cubit.state.titleSlide,
                                            (val) => cubit.updateSlide(-1,
                                                textColor: val))),
                              )),
                        ),
                        Positioned(
                          bottom: sin(imageRad) * 40 + 30,
                          right: imageRad * 90 / pi - 30,
                          child: Transform.rotate(
                              angle: -imageRad + pi / 2,
                              child: GestureDetector(
                                  onTap: () {
                                    controller.reverse();
                                    Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () => setState(() {
                                              edit = false;
                                            }));
                                    cubit.updateTitle(ImageSlide());
                                    cubit.pickImage(-1);
                                  },
                                  child: const Icon(Icons.image, size: 25))),
                        ),
                        Positioned(
                          bottom: sin(textRad) * 40 + 30,
                          right: textRad * 90 / pi - 30,
                          child: Transform.rotate(
                              angle: -textRad + pi / 2,
                              child: GestureDetector(
                                  onTap: () {
                                    controller.reverse();
                                    Future.delayed(
                                        const Duration(milliseconds: 200), () {
                                      if (!isText) {
                                        cubit.updateTitle(TextSlide('Untitled',
                                            Colors.white, Colors.black));
                                      }
                                      controller2.forward();
                                    });
                                  },
                                  child: const Icon(Icons.text_increase,
                                      size: 25))),
                        ),
                      ],
                    )
                  ],
                ),
              )).gestures(onTap: widget.tapHeader),
          actions: [
            TextButton(
                onPressed: loading ? null : cubit.saveShow,
                child: const Text('Save')
                    .textColor(loading ? Colors.grey : Colors.black)
                    .padding(all: 5)
                    .decorated(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)))
          ]),
    );
  }

  void showColorPicker(
      BuildContext context, Slide slide, Function(Color) onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: (slide as TextSlide).backgroundColor,
            onColorChanged: onChanged,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
