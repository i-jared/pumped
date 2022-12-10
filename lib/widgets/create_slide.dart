import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/models/slide_type.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:styled_widget/styled_widget.dart';

class CreateSlide extends StatelessWidget {
  final int i;
  const CreateSlide({required this.i, super.key});
  @override
  Widget build(BuildContext context) {
    final createShowCubit = BlocProvider.of<CreateShowCubit>(context);
    final slide = (i >= createShowCubit.state.slides.length)
        ? null
        : createShowCubit.state.slides[i];
    return <Widget>[
      const SizedBox(height: 150),
      if (slide != null) _buildPreview(context),
      if (slide == null) _buildChooseSlide(context),
      const SizedBox(height: 20),
      if (slide is TextSlide) ..._buildTextEntry(context, slide),
      if (slide is ImageSlide) _buildImageEntry(context, slide),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.center);
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
      createShowCubit.pickImage(i);
    });
  }

  List<Widget> _buildTextEntry(BuildContext context, TextSlide slide) {
    final createShowCubit = BlocProvider.of<CreateShowCubit>(context);
    return [
      //
      // text field
      //
      TextFormField(
        onChanged: (val) => createShowCubit.updateSlide(i, text: val),
        decoration: const InputDecoration(hintText: 'Enter Quote Here'),
      ).padding(horizontal: 50),
      const SizedBox(height: 20),
      //
      // background color selector
      //
      [
        Container().height(30).width(30).decorated(
            color: slide.backgroundColor,
            borderRadius: BorderRadius.circular(15)),
        const SizedBox(width: 15),
        const Text('Background Color'),
      ].toRow().padding(horizontal: 50).gestures(
          onTap: () => showColorPicker(context, slide,
              (val) => createShowCubit.updateSlide(i, backgroundColor: val))),
      const SizedBox(height: 20),
      //
      // text color selector
      //
      [
        Container().height(30).width(30).decorated(
            color: slide.textColor, borderRadius: BorderRadius.circular(15)),
        const SizedBox(width: 15),
        const Text('Text Color'),
      ].toRow().padding(horizontal: 50).gestures(
          onTap: () => showColorPicker(context, slide,
              (val) => createShowCubit.updateSlide(i, textColor: val))),
    ];
  }

  Widget _buildPreview(context) {
    final createShowCubit = BlocProvider.of<CreateShowCubit>(context);
    final slide = createShowCubit.state.slides[i];
    return (slide is TextSlide
            ? AutoSizeText(
                slide.text,
                style: TextStyle(fontSize: 40, color: slide.textColor),
                textAlign: TextAlign.center,
              ).center()
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
        .center();
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
          onPressed: () => cubit.createSlide(SlideType.text),
          icon: Icon(Icons.text_increase_outlined),
          iconSize: 30,
        ),
        Text('Text Slide')
      ].toColumn(mainAxisAlignment: MainAxisAlignment.center),
      [
        IconButton(
            onPressed: () => cubit.createSlide(SlideType.image),
            icon: Icon(Icons.image)),
        Text('Image Slide')
      ].toColumn(mainAxisAlignment: MainAxisAlignment.center),
    ]
        .toRow(mainAxisAlignment: MainAxisAlignment.spaceEvenly)
        .height(400)
        .width(400)
        .center();
  }
}
