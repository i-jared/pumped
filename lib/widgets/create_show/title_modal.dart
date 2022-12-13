import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/create_show/create_show_state.dart';

class TitleModal extends StatelessWidget {
  final CreateShowCubit cubit;
  final String titleText;
  const TitleModal({required this.cubit, required this.titleText, super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateShowCubit>.value(
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
                    padding: const EdgeInsets.all(8.0),
                    height: 350.0,
                    child: Column(
                      children: [
                        const Text(
                          'Edit Title Slide',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            // The modal's title
                            Stack(
                              children: [
                                const Text('text slide')
                                    .opacity(
                                        animate: true,
                                        (state.titleSlide is TextSlide) ? 0 : 1)
                                    .animate(const Duration(milliseconds: 200),
                                        Curves.linear)
                                    .center(),
                                if (state.titleSlide is TextSlide)
                                  _buildTextList(context, state, cubit)
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
                                  titleText,
                                  (state.titleSlide as TextSlide)
                                      .backgroundColor,
                                  (state.titleSlide as TextSlide).textColor,
                                ));
                              } else {
                                cubit.updateTitle(TextSlide(
                                    'Untitled', Colors.white, Colors.black));
                              }
                            }).expanded(),
                            // The modal's message
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
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
                        const Spacer(),
                        TextButton(
                          child: const Text('Finish'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ));
            }));
  }

  Widget _buildTextList(
      BuildContext context, CreateShowState state, CreateShowCubit cubit) {
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
}
