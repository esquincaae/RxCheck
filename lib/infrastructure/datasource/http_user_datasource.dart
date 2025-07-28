import 'dart:io';
import 'package:http/http.dart' as http;

class HttpUserDataSource {
  final String baseUrl;
  HttpUserDataSource(this.baseUrl);
  
  Future<http.Response> getUser(String token, String curp) {
    return http.get(
      Uri.parse('$baseUrl/users/$curp'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.StreamedResponse> updateProfile(
    String token,
    String curp,
    Map<String, String> fields,
  ) {
    final uri = Uri.parse('$baseUrl/users/$curp');
    final req = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token';
    req.fields.addAll(fields);
    return req.send();
  }

  Future<http.StreamedResponse> updateImage(
    String token,
    String curp,
    File imageFile, {
    Map<String, String>? extraFields,
  }) async {
    final uri = Uri.parse('$baseUrl/users/$curp');
    final req = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token';

    req.files.add(await http.MultipartFile.fromPath('imagen', imageFile.path));
    if (extraFields != null) req.fields.addAll(extraFields);
    return req.send();
  }
}