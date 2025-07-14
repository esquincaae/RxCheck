import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/medication.dart';

class ApiService {
  final String _baseUrl = 'https://api.rxcheck.icu';

  // Obtener lista de recetas del usuario
  Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse('$_baseUrl/recipe'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Recipe.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener productos');
    }
  }

  // Obtener detalle de recetas por id
  Future<List<Medication>> fetchRecipeDetail(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/recipe/$id'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Medication.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener los medicamentos de la receta');
    }
  }
}





