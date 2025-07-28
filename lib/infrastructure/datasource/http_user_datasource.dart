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

  Future<http.StreamedResponse> updateImage(String token, String curp, File imageFile) async {
    var uri = Uri.parse('$baseUrl/user/users/$curp');
    var request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Creamos primero el MultipartFile
    final multipartFile = await http.MultipartFile.fromPath(
      'imagen',
      imageFile.path,
    );
    request.files.add(multipartFile);

    return request.send();
  }

  Future<http.StreamedResponse> updateProfile(
      String token, String curp, Map<String, String> fields) async {
    var uri = Uri.parse('$baseUrl/user/users/$curp');
    var request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    return request.send();
  }
}
