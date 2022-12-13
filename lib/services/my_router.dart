import 'package:flutter/material.dart';
import 'package:pumped/imports.dart';

class MyRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey();
  static void showSnackBar(String message) {
    messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.white));
  }

  static void showErrorSnackBar(String message) {
    messengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message).textColor(Colors.white),
      backgroundColor: Colors.red.shade300,
    ));
  }
}
