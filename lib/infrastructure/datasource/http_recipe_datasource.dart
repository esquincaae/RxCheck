import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpRecipeDataSource {
  final String baseUrl;
  HttpRecipeDataSource(this.baseUrl);

  Future<http.Response> getRecipes(String token) {
    return http.get(
      Uri.parse('$baseUrl/recipe'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> getMedications(int recipeId, String token) {
    return http.get(
      Uri.parse('$baseUrl/recipe/$recipeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> getMedicationsByQr(String qr, String token) {
    return http.get(
      Uri.parse('$baseUrl/recipe/verify/$qr'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> getQrImage(int recipeId, String token) {
    return http.get(
      Uri.parse('$baseUrl/recipe/$recipeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> supplyMedications(String qr, List<int> meds, String token) {
    return http.post(
      Uri.parse('$baseUrl/recipe/supply/$qr'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'medications': meds}),
    );
  }
}
