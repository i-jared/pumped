import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/pages/music_selector.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/create_show/create_show_state.dart';
import 'package:pumped/widgets/create_show/title_modal.dart';

class CreateShowAppBar extends StatelessWidget {
  final double scrollExtent;
  final TextEditingController textController;
  final VoidCallback tapHeader;
  const CreateShowAppBar(
      {required this.scrollExtent,
      required this.textController,
      required this.tapHeader,
      super.key});
  @override
  Widget build(BuildContext context) {
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
              toolbarOptions: const ToolbarOptions(
                  copy: false, selectAll: false, paste: false, cut: false),
              onTap: () {
                scrollExtent == 1.0 ? tapHeader() : null;
              },
              controller: textController,
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
                  onTap: () => Navigator.of(context).pop(),
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
                          opacity: 1 - scrollExtent,
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
                    Positioned(
                        right: 5,
                        bottom: 25,
                        child: Opacity(
                          opacity: 1 - scrollExtent,
                          child: const Icon(Icons.edit_outlined, size: 25)
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

  _pushTitleModal(BuildContext context, CreateShowCubit cubit) {
    showDialog(
        context: context,
        builder: (context) {
          return TitleModal(cubit: cubit, titleText: textController.text);
        });
  }
}
