import 'package:flutter_local_notifications/flutter_local_notifications.dart';

extension Format on Time {
  String hhmmp() {
    return '${(hour % 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'pm' : 'am'}';
  }
}
