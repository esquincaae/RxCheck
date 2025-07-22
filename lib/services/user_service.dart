import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final _baseUrl = dotenv.env['API_URL'];

class UserService {
  final _secureStorage = const FlutterSecureStorage();
  final _prefs = SharedPreferences.getInstance();

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _prefs;
    final curp = prefs.getString('curp');
    final token = await _secureStorage.read(key: 'authToken');
    if (curp == null || token == null) {
      return null;
    }else{
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/user/users/$curp'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          return null;
        }
      } catch (e) {
        print('Error al obtener datos del usuario');
        return null;
      }
    }

  }

  Future<String?> updateUserImage(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final curp = prefs.getString('curp');
      final token = await _secureStorage.read(key: 'authToken');
      final nombre = await prefs.getString('nombre');
      final userEmail = await _secureStorage.read(key: 'userEmail');
      final userPass = await _secureStorage.read(key: 'userPassword');
      print('$curp - $token');

      if (curp == null || token == null) {
        return null;
      }

      var uri = Uri.parse('$_baseUrl/user/users/$curp');
      var request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nombre'] = nombre ?? '';
      request.fields['email'] = userEmail ?? '';
      request.fields['password'] = userPass ?? '';
      request.fields['curp'] = curp;
      request.files.add(await http.MultipartFile.fromPath('imagen', imageFile.path));


      var response = await request.send().timeout(const Duration(seconds: 5));
      var responseBody = await response.stream.bytesToString();
      var imageUrl = jsonDecode(responseBody)['imagen'];
      print('Response: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error al actualizar el perfil');
      return null;
    }
  }

  Future<bool> updateUserProfile({required String email, required String phone,//<--------------------------------UpdateProfile
    required String direction}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final curp = prefs.getString('curp');
      final token = await _secureStorage.read(key: 'authToken');
      final nombre = await prefs.getString('nombre');
      final userEmail = await _secureStorage.read(key: 'userEmail');
      final userPass = await _secureStorage.read(key: 'userPassword');
      print('$curp - $token');

      if (curp == null || token == null) {
        return false;
      }

      var uri = Uri.parse('$_baseUrl/user/users/$curp');
      var request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['email'] = email;
      request.fields['telefono'] = phone;
      request.fields['domicilio'] = direction;
      request.fields['nombre'] = nombre ?? '';
      request.fields['email'] = userEmail ?? '';
      request.fields['password'] = userPass ?? '';
      request.fields['curp'] = curp;


      var response = await request.send().timeout(const Duration(seconds: 5));
      var responseBody = await response.stream.bytesToString();

      print('Response: $responseBody');

      print('USERSERVICE - Response status code - ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar el perfil');
      return false;
    }
  }

  Future<User> getUserByCurp(String curp) async {
    final response = await http.get(Uri.parse('$_baseUrl/user/users/$curp'),
        headers: {'Authorization': 'Bearer ${await AuthService().getToken()}'})
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return User.fromJson(jsonData);
    } else {
      throw Exception('Error al obtener usuario');
    }
  }

  Future<bool> getUserByCurpExists(String curp) async {
    final response = await http.get(Uri.parse('$_baseUrl/user/users/$curp'),
        headers: {'Authorization': 'Bearer ${await AuthService().getToken()}'});
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

}
