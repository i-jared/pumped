import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pumped/imports.dart';
import 'package:pumped/pages/upload_display.dart';
import 'package:pumped/state/notify/notify_cubit.dart';
import 'package:pumped/pages/notifications_display.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final notifyCubit = context.watch<NotifyCubit>();
    return Drawer(
        width: 100,
        backgroundColor: Colors.black,
        child: Column(
          children: [
            DrawerHeader(child: const Text('🔥').fontSize(50)),
            IconButton(
              onPressed: () async {
                if (notifyCubit.state.hasPermission == null) {
                  await notifyCubit.init();
                } else if (notifyCubit.state.hasPermission == false) {
                  // TODO: request permission somehow
                }
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const NotificationsDisplay()));
              },
              icon: const Icon(Icons.alarm, color: Colors.white),
            ),
            const Divider(color: Colors.grey),
            IconButton(
              icon: const Icon(Icons.rocket, color: Colors.white),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const UploadDisplay())),
            ),
            const Divider(color: Colors.grey),
            IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => null),
            const Divider(color: Colors.grey),
            // IconButton(
            // icon: const Icon(Icons.settings, color: Colors.white),
            // onPressed: () => getIt<NotifyService>().test(),
            // ),
          ],
        ));
  }
}
