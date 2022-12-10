import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/pages/music_selector.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/create_show/create_show_state.dart';
import 'package:pumped/state/shows/shows_cubit.dart';
import 'package:pumped/widgets/create_slide.dart';
import 'package:styled_widget/styled_widget.dart';

class CreateShowPage extends StatefulWidget {
  const CreateShowPage({super.key});
  @override
  State<StatefulWidget> createState() => _CreateShowPageState();
}

class _CreateShowPageState extends State<CreateShowPage> {
  late TextEditingController _textController;
  // late AnimationController _animateController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _textController = TextEditingController(text: 'Untitled');

    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, isScrolled) =>
                    [_buildCustomAppBar(context)],
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
          return CreateSlide(i: i);
        },
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    final cubit = context.watch<CreateShowCubit>();
    final loading = cubit.state is LoadingCreateShowState;
    Slide ts = cubit.state.titleSlide;
    bool isText = ts.runtimeType == TextSlide;
    TextSlide? textSlide = isText ? ts as TextSlide : null;
    ImageSlide? imageSlide = isText ? null : ts as ImageSlide;

    final title = isText
        ? IntrinsicWidth(
            child: TextField(
              onChanged: (val) => cubit.updateSlide(-1, text: val),
              toolbarOptions: ToolbarOptions(
                  copy: false, selectAll: false, paste: false, cut: false),
              onTap: () {
                _scrollController.hasClients &&
                        _scrollController.position.atEdge &&
                        _scrollController.offset > 0
                    ? tapHeader()
                    : null;
              },
              controller: _textController,
              style: TextStyle(color: textSlide!.textColor),
              cursorColor: textSlide.textColor,
              decoration: InputDecoration(
                  hintText: 'Enter your title',
                  hintStyle: TextStyle(color: textSlide.textColor),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero),
              scrollPadding: EdgeInsets.zero,
            ),
          )
        : const SizedBox.shrink();

    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverAppBar(
          pinned: true,
          expandedHeight: 350,
          leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child:
                      Icon(Icons.chevron_left, size: 40, color: Colors.black))
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
                expandedTitleScale: 3.0,
                title: Stack(
                  children: [
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: title.padding(right: 10)),
                    Positioned(
                        right: 5,
                        bottom: 40,
                        child: Opacity(
                          opacity: !_scrollController.hasClients
                              ? 1
                              : 1 -
                                  _scrollController.offset /
                                      _scrollController
                                          .position.maxScrollExtent,
                          child: Icon(Icons.music_note_outlined, size: 15)
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
                                                  child: MusicSelector())))),
                        )),
                    Positioned(
                        right: 5,
                        bottom: 15,
                        child: Opacity(
                          opacity: !_scrollController.hasClients
                              ? 1
                              : 1 -
                                  _scrollController.offset /
                                      _scrollController
                                          .position.maxScrollExtent,
                          child: Icon(Icons.edit_outlined, size: 15)
                              .padding(all: 2)
                              .decorated(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100))
                              .gestures(
                                  onTap: () => _pushTitleModal(context, cubit)),
                        ))
                  ],
                ),
              )).gestures(onTap: tapHeader),
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

  void tapHeader() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
          _scrollController.offset <
                  _scrollController.position.maxScrollExtent / 2
              ? _scrollController.position.maxScrollExtent
              : 0,
          duration: Duration(milliseconds: 200),
          curve: Curves.bounceInOut);
    }
  }

  Widget _buildImageEntry(BuildContext context, ImageSlide slide) {
    final createShowCubit = context.read<CreateShowCubit>();
    return [
      Container().height(30).width(30).decorated(
          color: Colors.white,
          borderRadius: slide.image == null ? null : BorderRadius.circular(15),
          image: slide.image == null
              ? null
              : DecorationImage(
                  image: FileImage(slide.image!), fit: BoxFit.cover)),
      const SizedBox(width: 15),
      const Text('Select Image'),
    ].toRow().padding(horizontal: 50).gestures(onTap: () async {
      createShowCubit.pickImage(-1);
    });
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

  void _pushTitleModal(BuildContext context, CreateShowCubit cubit) {
    // Create a dialog widget

    final dialog = BlocProvider<CreateShowCubit>.value(
      value: cubit,
      child: BlocBuilder<CreateShowCubit, CreateShowState>(
          bloc: cubit,
          builder: (context, state) {
            return Dialog(
                // Set the shape of the modal
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // Add the content of the modal
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  height: 350.0,
                  child: Column(
                    children: [
                      Text(
                        'Edit Title Slide',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          // The modal's title
                          Stack(
                            children: [
                              Text('text slide')
                                  .opacity(
                                      animate: true,
                                      (state.titleSlide is TextSlide) ? 0 : 1)
                                  .animate(Duration(milliseconds: 200),
                                      Curves.linear)
                                  .center(),
                              if (state.titleSlide is TextSlide)
                                _buildTextList(state, cubit)
                            ],
                          )
                              .height(150)
                              .decorated(
                                  border: Border.all(
                                      color: state.titleSlide is TextSlide
                                          ? Colors.blue
                                          : Colors.grey,
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(12.0))
                              .gestures(onTap: () {
                            if (state.titleSlide is TextSlide) {
                              cubit.updateTitle(TextSlide(
                                _textController.text,
                                (state.titleSlide as TextSlide).backgroundColor,
                                (state.titleSlide as TextSlide).textColor,
                              ));
                            } else {
                              cubit.updateTitle(TextSlide(
                                  'Untitled', Colors.white, Colors.black));
                            }
                          }).expanded(),
                          // The modal's message
                          SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('image slide'),
                            ],
                          )
                              .height(150)
                              .decorated(
                                  border: Border.all(
                                      color: state.titleSlide is ImageSlide
                                          ? Colors.blue
                                          : Colors.grey,
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(12.0))
                              .gestures(onTap: () {
                            cubit.updateTitle(ImageSlide());
                            cubit.pickImage(-1);
                            Navigator.of(context).pop();
                          }).expanded(),
                          // A button to close the modal
                        ],
                      ),
                      Spacer(),
                      TextButton(
                        child: Text('Finish'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ));
          }),
    );

    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  Widget _buildTextList(CreateShowState state, CreateShowCubit cubit) {
    return [
      [
        Container().height(15).width(15).decorated(
            color: (state.titleSlide as TextSlide).backgroundColor,
            border: Border.all(),
            borderRadius: BorderRadius.circular(15)),
        const SizedBox(width: 5),
        const Text('Background Color'),
      ].toRow().padding(horizontal: 10).gestures(
          onTap: () => showColorPicker(context, state.titleSlide,
              (val) => cubit.updateSlide(-1, backgroundColor: val))),
      const SizedBox(height: 20),
      [
        Container().height(15).width(15).decorated(
            color: (state.titleSlide as TextSlide).textColor,
            border: Border.all(),
            borderRadius: BorderRadius.circular(15)),
        const SizedBox(width: 5),
        const Text('Text Color'),
      ].toRow().padding(horizontal: 10).gestures(
          onTap: () => showColorPicker(context, state.titleSlide,
              (val) => cubit.updateSlide(-1, textColor: val))),
    ]
        .toColumn(mainAxisAlignment: MainAxisAlignment.center)
        .opacity(animate: true, (state.titleSlide is TextSlide) ? 1 : 0)
        .animate(Duration(milliseconds: 200), Curves.linear);
  }
}
