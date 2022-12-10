import 'dart:convert';

import 'package:http/http.dart' as http;

class Api {
  Api._();
  static Api get instance => Api._();
  Future<Map<String, dynamic>> get(
      String url, Map<String, String>? headers) async {
    try {
      Uri uri = Uri.parse(url);
      final response = await http.get(uri, headers: headers);
      final result = json.decode(response.body);
      return result;
    } catch (e, stack) {
      throw Exception('Get Request Error:\n\n$e\n\n$stack');
    }
  }
}
