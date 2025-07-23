import 'package:dio/dio.dart';
import '../models/recipe.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = dotenv.env['API_URL'] ?? '';


final storage = FlutterSecureStorage();
final Dio dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 5),
  ),
);

Future<List<Recipe>> fetchRecipes() async {
  final token = await storage.read(key: 'authToken');

  try {
    final response = await dio.get(
      '/recipe',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );


    if (response.statusCode == 200) {
      final decoded = response.data;
      final data = decoded['data'] as List<dynamic>;
      List<Recipe> recipes = data.map((e) => Recipe.fromJson(e)).toList();
      //recipes.map();
      return recipes.reversed.toList();
    } else {
      throw Exception('Error en la respuesta: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error al obtener recetas');
  }
}
