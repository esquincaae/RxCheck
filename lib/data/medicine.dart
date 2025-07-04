import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine.dart';

Future<List<Medicine>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<Medicine> recipes = [];

    for (var item in data) {
      recipes.add(Medicine.fromJson(item));
    }

    // Imprimir los títulos de los productos en consola
    for (var p in recipes) {
      print('Medicamento: ${p.name} ');
    }

    return recipes;
  } else {
    throw Exception('Error al obtener productos');
  }
}
