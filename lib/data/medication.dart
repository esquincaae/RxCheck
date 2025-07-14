import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/medication.dart';

String apiUrl = 'https://api.rxcheck.icu';
final storage = FlutterSecureStorage();
final token = storage.read(key: 'authToken');

Future<List<Medication>> fetchMedicines(int recipeId) async {
  final token = await storage.read(key: 'authToken');
  print('MEDICINES - Recipe ID: $recipeId');
  print('$token');
  final response = await http.get(
    Uri.parse('$apiUrl/recipe/$recipeId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    final data = decoded['data'] as Map<String, dynamic>;

    final List<dynamic> medicationsJson = data['medications'] ?? [];
    List<Medication> medications = medicationsJson
        .map((item) => Medication.fromJson(item))
        .toList();

    // Imprimir textos de medicamentos en consola
    for (var m in medications) {
      print('Medicamento: ${m.text}');
    }

    return medications;
  } else {
    throw Exception('Error al obtener medicamentos: ${response.statusCode}');
  }
}

Future<String> fetchQrImage(int recipeId) async {
  final token = await storage.read(key: 'authToken');
  print('QR FETCH - Recipe ID: $recipeId');
  final response = await http.get(
    Uri.parse('$apiUrl/recipe/$recipeId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    final data = decoded['data'] as Map<String, dynamic>;

    final qrImage = data['qr_image'];
    print('QR: $qrImage');
    return qrImage ?? '';
  } else {
    throw Exception('Error al obtener QR: ${response.statusCode}');
  }
}
