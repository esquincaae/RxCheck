import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

final _apiUrl = dotenv.env['API_URL'];
final _baseUrl = '$_apiUrl/user';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  late SharedPreferences _prefs;

  AuthService() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final String message = decoded['message'] ?? '';
      final String accessToken = decoded['data']['access_token'] ?? '';
      final Map<String, dynamic> user = decoded['data']['user'] ?? {};

      // Puedes guardar en SharedPreferences y SecureStorage si necesitas persistencia
      await _prefs.setString('curp', user['curp'] ?? '');
      await _prefs.setString('nombre', user['nombre'] ?? '');
      await _prefs.setString('role', user['role'] ?? '');
      await _prefs.setString('direccion', user['direccion'] ?? '');

      await _secureStorage.write(key: 'curp', value: user['curp'] ?? '');
      await _secureStorage.write(key: 'userEmail', value: email);
      await _secureStorage.write(key: 'authToken', value: accessToken);
      await _secureStorage.write(key: 'userPassword', value: password);

      final Map<String, dynamic> userData = {
        'message': message,
        'access_token': accessToken,
        'id': user['id'] ?? '',
        'nombre': user['nombre'] ?? '',
        'email': user['email'] ?? '',
        'role': user['role'] ?? '',
        'curp': user['curp'] ?? '',
      };

      print('Datos de login: $userData');
      return true;
    } else {
      final decoded = jsonDecode(response.body);
      String message = decoded['message'] ?? '';
      throw Exception('$message');
    }
  }


  Future<bool> signUp(String rfc, String curp, String nombre, String role, String email, String password, String telefono,
                      String direccion, String primerApellido, String segundoApellido,) async { //<------------------- REGISTRO
    try {
      final body = jsonEncode({
        'rfc': rfc,
        'curp': curp,
        'nombre': nombre,
        'apellidoPaterno': primerApellido,
        'apellidoMaterno': segundoApellido,
        'telefono': telefono,
        'email': email,
        'password': password,
        'role': role,
        'domicilio': direccion,
        });

      print('Body enviado: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error al registrar usuario: ${response.statusCode}');
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error al registrar usuario');
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<void> signOut() async { //<-------------------------------------------------------- CERRAR SESION
    final token = await _secureStorage.read(key: 'authToken');
    if (token != null) {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token'},
      );
    }

    await _prefs.clear();
    await _secureStorage.deleteAll();
  }

  Future<String> getCurp() async {
    return await _secureStorage.read(key: 'curp') ?? '';
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'authToken') ?? '';
  }


  Future<bool> sendPasswordReset(String email) async {
    try{
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/request-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 201) {
          return true;
      } else {
        throw Exception('Error al enviar el correo de recuperación');
      }

    }catch(e){
      rethrow;
    }
  }

  Future<bool> ConfirmPasswordReset(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/confirm-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword}),
      );

      if (response.statusCode == 201) {
        await _secureStorage.write(key: 'userPassword', value: newPassword);
        return true;
      }else{
        throw Exception('Error al confirmar el cambio  de contraseña');
      }
    }catch(e){
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    final curp = await _secureStorage.read(key: 'curp');
    final url = Uri.parse('$_baseUrl/users/$curp');

    final response = await http.delete(url);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('Cuenta Eliminada Exitosamente: ${response.body}');
      _secureStorage.deleteAll();
      _prefs.clear();
    }else{
      print('Error al eliminar cuenta: ${response.statusCode}');
      throw Exception('Error al eliminar cuenta: ${response.body}');
    }
  }

}
