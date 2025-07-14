import 'package:dio/dio.dart';
import '../models/recipe.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
final Dio dio = Dio();
final String baseUrl = 'https://api.rxcheck.icu';

Future<List<Recipe>> fetchRecipes() async {
  final token = await storage.read(key: 'authToken');
  print('RECIPEDATA - Token: $token');

  try {
    final response = await dio.get(
      '$baseUrl/recipe',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final decoded = response.data; // Dio ya devuelve Map<String, dynamic>
      final data = decoded['data'] as List<dynamic>;

      List<Recipe> recipes = data.map((e) => Recipe.fromJson(e)).toList();

      // Imprimir recetas en consola
      for (var r in recipes) {
        print('Receta ID: ${r.id}, Fecha: ${r.issue_at}');
      }

      return recipes;
    } else {
      throw Exception('Error en la respuesta: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al obtener recetas: $e');
    throw Exception('Error al obtener recetas');
  }
}
