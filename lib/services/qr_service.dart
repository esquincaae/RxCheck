import 'dart:convert';
import 'package:RxCheck/models/medication.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/recipe.dart';
final _baseUrl = dotenv.env['API_URL'];

class QrService {
  final _secureStorage = const FlutterSecureStorage();

  Future<bool> updateStatusMedications(medication) async {
    final token = await _secureStorage.read(key: 'authToken');
    try {
      final body = jsonEncode({
        'medications': medication,
      });
      print('Body enviado: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/recipe/supply/'),
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'},
        body: body,
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al suplir medica');
      }
    } catch (e) {
      rethrow;
    }
  }


}