import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/medication.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['API_URL'];

final storage = FlutterSecureStorage();
final token = storage.read(key: 'authToken');

Future<List<Medication>> fetchMedicines(int recipeId) async {
  final token = await storage.read(key: 'authToken');
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

    return medications;
  } else {
    throw Exception('Error al obtener medicamentos: ${response.statusCode}');
  }
}

Future<List<Medication>> fetchMedicinesQrCode(String? qrCode) async {
  final token = await storage.read(key: 'authToken');
  final response = await http.get(
    Uri.parse('$apiUrl/recipe/verify/$qrCode'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  print(response.statusCode);
  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    final data = decoded['data'] as Map<String, dynamic>;
    print(data);

    final List<dynamic> medicationsJson = data['medications'] ?? [];
    List<Medication> medications = medicationsJson
        .map((item) => Medication.fromJson(item)).toList();

    return medications;
  } else if (response.statusCode == 404) {
    throw Exception('Esta Receta ya ha sido surtida por una Farmacia');
  }else {
    throw Exception('Error al obtener medicamentos: ${response.statusCode}');
  }
}

Future<String> fetchQrImage(int recipeId) async {
  final token = await storage.read(key: 'authToken');
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
    return qrImage ?? '';
  } else {
    throw Exception('Error al obtener QR: ${response.statusCode}');
  }
}
