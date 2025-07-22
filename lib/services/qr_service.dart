import 'dart:convert';
import 'package:RxCheck/models/medication.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/recipe.dart';
final _baseUrl = dotenv.env['API_URL'];

class QrService {
  final _secureStorage = const FlutterSecureStorage();

  Future<bool> updateStatusMedications(List<int> medication) async {
    final token = await _secureStorage.read(key: 'authToken');
    final qr = await _secureStorage.read(key: 'qrCode');
    try {
      final body = jsonEncode({
        'medications': medication,
      });
      print('Body enviado: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/recipe/supply/$qr'),
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'},
        body: body,
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('$data');
        print('STATUSCODE: ${response.statusCode}');
        return true;
      } else
        throw Exception('Error al surtir medicamentos');
    } catch (e) {
      rethrow;
    }
  }


}