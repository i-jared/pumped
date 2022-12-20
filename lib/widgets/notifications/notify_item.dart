import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/my_notification.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/state/notify/notify_cubit.dart';

class NotifyItem extends StatefulWidget {
  final bool isText;
  final MyNotification notif;
  final Slide? slide;
  const NotifyItem(
      {required this.isText,
      required this.notif,
      required this.slide,
      super.key});
  @override
  State<NotifyItem> createState() => _NotifyItemState();
}

class _NotifyItemState extends State<NotifyItem> {
  late bool edit;
  @override
  void initState() {
    super.initState();
    edit = false;
  }

  @override
  Widget build(BuildContext context) {
    final notifyCubit = context.watch<NotifyCubit>();
    return Stack(
      children: [
        ListTile(
          onLongPress: () => setState(() => edit = true),
          visualDensity: const VisualDensity(horizontal: 4, vertical: 4),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: IconButton(
            icon: const Icon(Icons.alarm),
            iconSize: 30,
            color: widget.notif.active ? Colors.deepOrange : Colors.black,
            onPressed: () => widget.notif.active
                ? notifyCubit.deactivate(widget.notif)
                : notifyCubit.activate(widget.notif),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.notif.time.hhmmp()).mood(),
              widget.notif.weekdays
                  .map((day) =>
                      Text(day.abbr()).italic().fontSize(12).padding(right: 5))
                  .toList()
                  .toRow()
            ],
          ),
          trailing: Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                  color: widget.isText
                      ? (widget.slide as TextSlide).backgroundColor
                      : null,
                  image: !widget.isText
                      ? DecorationImage(
                          image: FileImage((widget.slide as ImageSlide).image!),
                          fit: BoxFit.cover)
                      : null),
              child: widget.isText
                  ? AutoSizeText(
                      (widget.slide as TextSlide).text,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ).center()
                  : null),
        ),
        AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.decelerate,
            right: !edit ? -300 : 0,
            child: Container(
                color: Colors.white,
                height: 75,
                width: 300,
                child: Row(
                  children: [
                    Text('delete?').textColor(Colors.red).alone(),
                    Spacer(),
                    Text('yes').alone().gestures(
                      onTap: () {
                        notifyCubit.delete(widget.notif);
                        setState(() => edit = false);
                      },
                    ),
                    SizedBox(width: 30),
                    Text('no').alone().gestures(
                          onTap: () => setState(() => edit = false),
                        ),
                  ],
                ).padding(horizontal: 30)))
      ],
    );
  }
}
