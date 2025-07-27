import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpAuthDataSource {
  final String baseUrl;
  HttpAuthDataSource(this.baseUrl);

  Future<http.Response> login(String email, String password) {
    return http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> register(Map<String, dynamic> data) {
    return http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  Future<http.Response> logout(String token) {
    return http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
  }

  Future<http.Response> requestPasswordReset(String email) {
    return http.post(
      Uri.parse('$baseUrl/auth/request-password-reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  Future<http.Response> confirmPasswordReset(String email, String code, String newPassword) {
    return http.post(
      Uri.parse('$baseUrl/auth/confirm-password-reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code, 'newPassword': newPassword}),
    );
  }

  Future<http.Response> deleteAccount(String identifier) {
    return http.delete(
      Uri.parse('$baseUrl/users/$identifier'),
    );
  }
}
