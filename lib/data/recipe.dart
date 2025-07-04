import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

Future<List<Recipe>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<Recipe> recipes = [];

    for (var item in data) {
      recipes.add(Recipe.fromJson(item));
    }

    // Imprimir los títulos de los productos en consola
    for (var p in recipes) {
      print('Receta: ${p.title} - \$${p.price}');
    }

    return recipes;
  } else {
    throw Exception('Error al obtener productos');
  }
}
