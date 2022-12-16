import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/models/my_notification.dart';
import 'package:pumped/models/show.dart';
import 'package:pumped/models/slide.dart';
import 'package:pumped/state/notify/notify_cubit.dart';
import 'package:pumped/state/notify/notify_state.dart';
import 'package:pumped/state/shows/shows_cubit.dart';
import 'package:pumped/state/shows/shows_state.dart';

class NotificationsDisplay extends StatefulWidget {
  const NotificationsDisplay({super.key});
  @override
  State<StatefulWidget> createState() => _NotificationsDisplayState();
}

class _NotificationsDisplayState extends State<NotificationsDisplay> {
  late bool creating;
  late List<Day> days;
  late Time? time;
  late Show? selectedShow;
  @override
  void initState() {
    super.initState();
    creating = false;
    days = [];
    time = null;
    selectedShow = null;
  }

  @override
  Widget build(BuildContext context) {
    final notifyCubit = context.watch<NotifyCubit>();
    final notifyState = notifyCubit.state;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications').mood(),
        ),
        body: notifyState is LoadedNotifyState
            ? _buildNotifications()
            : notifyState is LoadingNotifyState
                ? notifyState.hasPermission == true
                    ? _buildLoading()
                    : _buildPermission()
                : const SizedBox.shrink(),
        floatingActionButton: FloatingActionButton.large(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.black,
            onPressed: () => setState(() => creating = !creating),
            tooltip: 'Create Notification',
            child: const Icon(Icons.add, size: 80)
                .rotate(angle: creating ? 3 * 3.14 / 4 : 0, animate: true)
                .animate(const Duration(milliseconds: 300), Curves.linear)));
  }

  Widget _buildLoading() => const CircularProgressIndicator().center();
  Widget _buildPermission() => const Text('Plz Enable Notifications').center();
  Widget _buildNotifications() {
    final notifyCubit = context.watch<NotifyCubit>();
    final showsState = context.watch<ShowsCubit>().state as LoadedShowsState;
    final notifyState = notifyCubit.state as LoadedNotifyState;
    return [
      AnimatedSize(
          curve: Curves.decelerate,
          duration: const Duration(milliseconds: 300),
          child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: creating ? 400 : 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCreateWidget())
              .backgroundColor(Colors.black)),
      if (notifyState.notifications.isEmpty) ...[
        const Spacer(),
        const Text('No Notifications Yet...').alone(),
        const Spacer(),
      ],
      if (notifyState.notifications.isNotEmpty) ...[
        ListView.builder(
          itemCount: notifyState.notifications.length,
          itemBuilder: (context, i) {
            MyNotification notif = notifyState.notifications[i];
            Show? show = showsState.shows
                .firstWhereOrNull((s) => s.uid == notif.showUid);
            Slide? slide = show?.titleSlide;
            bool isText = show?.titleSlide is TextSlide;
            return ListTile(
              onLongPress: () => null,
              visualDensity: const VisualDensity(horizontal: 4, vertical: 4),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: IconButton(
                icon: const Icon(Icons.alarm),
                iconSize: 30,
                color: notif.active ? Colors.deepOrange : Colors.black,
                onPressed: () => notif.active
                    ? notifyCubit.deactivate(notif)
                    : notifyCubit.activate(notif),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.time.hhmmp()).mood(),
                  notif.weekdays
                      .map((day) => Text(day.abbr())
                          .italic()
                          .fontSize(12)
                          .padding(right: 5))
                      .toList()
                      .toRow()
                ],
              ),
              trailing: Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                      color:
                          isText ? (slide as TextSlide).backgroundColor : null,
                      image: !isText
                          ? DecorationImage(
                              image: FileImage((slide as ImageSlide).image!))
                          : null),
                  child: isText
                      ? AutoSizeText(
                          (slide as TextSlide).text,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ).center()
                      : null),
            );
          },
        ).expanded(),
      ],
    ].toColumn();
  }

  Widget _buildCreateWidget() {
    final notifyCubit = context.watch<NotifyCubit>();
    return [
      [
        [
          const Text('Time of Day').bold().textColor(Colors.white).fontSize(20),
          const SizedBox(height: 10),
          _buildTime(),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
        [
          const Text('Days of Week')
              .bold()
              .textColor(Colors.white)
              .fontSize(20),
          const SizedBox(height: 10),
          Day.values
              .map((day) => _buildDayOfWeek(day))
              .toList()
              .toRow(mainAxisAlignment: MainAxisAlignment.spaceAround),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
        [
          const Text('Show').bold().textColor(Colors.white).fontSize(20),
          const SizedBox(height: 10),
          _buildShows(),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
      ].toColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ),
      IconButton(
              onPressed: (time == null || days.isEmpty || selectedShow == null)
                  ? null
                  : () {
                      notifyCubit.create(time!, days, selectedShow!);
                      setState(() {
                        time = null;
                        days = [];
                        selectedShow = null;
                        creating = false;
                      });
                    },
              icon: const Icon(Icons.save),
              iconSize: 50,
              disabledColor: Colors.grey,
              color: Colors.white)
          .positioned(top: 0, right: 0),
    ].toStack();
  }

  Widget _buildDayOfWeek(Day day) {
    return TextButton(
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -3, vertical: 0),
      ),
      child: Text(day.abbr())
          .textColor(days.contains(day) ? Colors.deepOrange : Colors.white),
      onPressed: () => onDayOfWeekPressed(day),
    );
  }

  Widget _buildTime() {
    return TextButton(
        child: Text(time == null ? 'Select Time' : time!.hhmmp())
            .textColor(time == null ? Colors.white : Colors.deepOrange),
        onPressed: () async {
          final tempTime = await showTimePicker(
              context: context, initialTime: TimeOfDay(hour: 6, minute: 0));
          if (tempTime == null) return;
          setState(() => time = Time(tempTime.hour, tempTime.minute, 0));
        });
  }

  Widget _buildShows() {
    final showsState = context.watch<ShowsCubit>().state as LoadedShowsState;
    if (showsState.shows.isEmpty) {
      return const Text('No Shows Yet...')
          .textColor(Colors.white)
          .bold()
          .center()
          .height(75);
    }
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: showsState.shows.length,
        itemBuilder: (context, i) {
          Show show = showsState.shows[i];
          Slide slide = show.titleSlide;
          bool isText = show.titleSlide is TextSlide;

          return Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                      border: selectedShow == show
                          ? Border.all(color: Colors.deepOrange, width: 2)
                          : null,
                      color:
                          isText ? (slide as TextSlide).backgroundColor : null,
                      image: !isText
                          ? DecorationImage(
                              image: FileImage((slide as ImageSlide).image!))
                          : null),
                  child: isText
                      ? AutoSizeText(
                          (slide as TextSlide).text,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ).center()
                      : null)
              .gestures(onTap: () => setState(() => selectedShow = show));
        }).height(75);
  }

  void onDayOfWeekPressed(Day day) {
    List<Day> tempDays = List<Day>.from(days);
    if (tempDays.contains(day)) {
      tempDays.remove(day);
    } else {
      tempDays.add(day);
    }
    setState(() => days = tempDays);
  }
}
