import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/slide_type.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';

class CreateSlide extends StatefulWidget {
  final int i;
  final Slide? slide;
  const CreateSlide({required this.i, this.slide, super.key});
  @override
  State<StatefulWidget> createState() => _CreateSlideState();
}

class _CreateSlideState extends State<CreateSlide> {
  late final int i;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late bool _editing;
  @override
  void initState() {
    super.initState();
    i = widget.i;
    _textController = TextEditingController();
    if (widget.slide is TextSlide) {
      _textController.text = (widget.slide as TextSlide).text;
    }
    _focusNode = FocusNode();
    _editing = false;
  }

  @override
  Widget build(BuildContext context) {
    CreateShowCubit cubit = context.watch<CreateShowCubit>();
    Slide? slide =
        i >= cubit.state.slides.length ? null : cubit.state.slides[i];

    return <Widget>[
      const SizedBox(height: 150),
      [
        const Text('Delete.').fontSize(40).bold().gestures(onTap: () {
          setState(() => _editing = false);
          cubit.deleteSlide(i);
        }),
        const SizedBox(height: 20),
        const Text('Reset.').fontSize(40).bold().gestures(onTap: () {
          setState(() => _editing = false);
          cubit.resetSlide(i);
        }),
        const SizedBox(height: 75),
        const Text('Cancel.')
            .fontSize(20)
            .bold()
            .gestures(onTap: () => setState(() => _editing = false)),
        const SizedBox(height: 20),
      ]
          .toColumn(mainAxisAlignment: MainAxisAlignment.end)
          .scrollable(physics: const NeverScrollableScrollPhysics())
          .height(animate: true, _editing ? 300 : 0)
          .animate(const Duration(milliseconds: 300), Curves.fastOutSlowIn),
      if (slide != null) _buildPreview(context),
      if (slide == null) _buildChooseSlide(context),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.center).scrollable();
  }

  Widget _buildPreview(context) {
    final createShowCubit = BlocProvider.of<CreateShowCubit>(context);
    final slide = createShowCubit.state.slides[i];
    return [
      (slide is TextSlide
              ? GestureDetector(
                  onTap: () => _focusNode.requestFocus(),
                  onLongPress: () => setState(() => _editing = true),
                  child: AbsorbPointer(
                    child: AutoSizeTextField(
                      wrapWords: false,
                      focusNode: _focusNode,
                      scrollPadding: EdgeInsets.zero,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      cursorColor: slide.textColor,
                      cursorWidth: 5,
                      maxLength: 100,
                      maxLines: null,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      controller: _textController,
                      onChanged: (val) =>
                          createShowCubit.updateSlide(i, text: val),
                      presetFontSizes: const [80, 60, 40, 20],
                      style: TextStyle(fontSize: 80, color: slide.textColor),
                      textAlign: TextAlign.center,
                    ).center().padding(vertical: 75),
                  ),
                )
              : slide is ImageSlide && slide.image == null
                  ? ([
                      IconButton(
                        onPressed: () => {
                          createShowCubit.pickImage(i),
                        },
                        icon: const Icon(Icons.image),
                        iconSize: 70,
                      ),
                      const Text('Image').fontSize(25).bold()
                    ].toColumn(mainAxisAlignment: MainAxisAlignment.center))
                  : Container())
          .height(500)
          .width(500 * 9 / 16)
          .decorated(
              color: slide is TextSlide ? slide.backgroundColor : Colors.white,
              image: slide is ImageSlide
                  ? slide.image == null
                      ? null
                      : DecorationImage(
                          image: FileImage(slide.image!), fit: BoxFit.cover)
                  : null,
              borderRadius: BorderRadius.circular(20),
              boxShadow: kElevationToShadow[8])
          .center(),
      if (slide is TextSlide)
        [
          [
            Container().height(30).width(30).decorated(
                // color: slide.backgroundColor,
                color: slide.backgroundColor,
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(15)),
            const Text('BG').bold(),
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.center).gestures(
              onTap: () => showColorPicker(
                  context,
                  slide,
                  (val) =>
                      createShowCubit.updateSlide(i, backgroundColor: val))),
          const SizedBox(height: 20),
          [
            Container().height(30).width(30).decorated(
                color: slide.textColor,
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(15)),
            const Text('TXT').bold(),
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.center).gestures(
              onTap: () => showColorPicker(context, slide,
                  (val) => createShowCubit.updateSlide(i, textColor: val)))
        ]
            .toColumn(crossAxisAlignment: CrossAxisAlignment.end)
            .positioned(top: 0, right: 0),
    ].toStack().gestures(onLongPress: () => setState(() => _editing = true));
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

  Widget _buildChooseSlide(BuildContext context) {
    final cubit = context.read<CreateShowCubit>();
    return [
      [
        IconButton(
          onPressed: () {
            cubit.createSlide(SlideType.text);
            _focusNode.requestFocus();
          },
          icon: const Icon(Icons.text_increase_outlined),
          iconSize: 70,
        ),
        const Text('Text').fontSize(25).italic()
      ].toColumn(mainAxisAlignment: MainAxisAlignment.center),
      const Divider(color: Colors.black).padding(horizontal: 40),
      [
        IconButton(
          onPressed: () => {
            cubit.createSlide(SlideType.image),
            cubit.pickImage(i),
          },
          icon: const Icon(Icons.image),
          iconSize: 70,
        ),
        const Text('Image').fontSize(25).bold()
      ].toColumn(mainAxisAlignment: MainAxisAlignment.center),
    ]
        .toColumn(mainAxisAlignment: MainAxisAlignment.spaceEvenly)
        .height(500)
        .width(500 * 9 / 16)
        .decorated(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: kElevationToShadow[8])
        .center();
  }
}
