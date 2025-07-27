import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HttpUserDataSource {
  final String baseUrl;
  HttpUserDataSource(this.baseUrl);

  Future<http.Response> getUser(String token, String curp) {
    return http.get(
      Uri.parse('$baseUrl/user/users/$curp'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.StreamedResponse> updateImage(String token, String curp, File imageFile) {
    var req = http.MultipartRequest('PUT', Uri.parse('$baseUrl/user/users/$curp'));
    req.headers['Authorization'] = 'Bearer $token';
    req.files.add(http.MultipartFile.fromPath('imagen', imageFile.path));
    return req.send();
  }

  Future<http.StreamedResponse> updateProfile(
      String token, String curp, Map<String, String> fields) {
    var req = http.MultipartRequest('PUT', Uri.parse('$baseUrl/user/users/$curp'));
    req.headers['Authorization'] = 'Bearer $token';
    req.fields.addAll(fields);
    return req.send();
  }
}
