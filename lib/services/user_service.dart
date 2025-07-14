import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart';

class UserService {
  final _baseUrl = 'https://api.rxcheck.icu';
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
        );
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          return null;
        }
      } catch (e) {
        print('Error al obtener datos del USERSERVICE: $e');
        return null;
      }
    }

  }

  Future<String?> uploadUserImage(File imageFile) async {
    try {
      final curp = await _secureStorage.read(key: 'curp');
      final token = await _secureStorage.read(key: 'authToken');

      if (curp == null || token == null) {
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/user/users/$curp'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data['photoUrl'];
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String email,
    required String phone,
    required String direction,
    String? photoUrl,
  }) async {
    try {
      final curp = await _secureStorage.read(key: 'curp');
      final token = await _secureStorage.read(key: 'authToken');

      if (curp == null || token == null) {
        return false;
      }

      final body = {
        'email': email,

        'phone': phone,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/user/users/$curp'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }

  Future<User> getUserByCurp(String curp) async {
    final response = await http.get(Uri.parse('$_baseUrl/user/users/$curp'),
        headers: {'Authorization': 'Bearer ${await AuthService().getToken()}'});
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return User.fromJson(jsonData);
    } else {
      throw Exception('Error al obtener usuario');
    }
  }

}
