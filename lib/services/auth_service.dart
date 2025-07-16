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

  Future<bool> reauthenticate(String email, String password) async { //<--------------- REAUTENTICACION
    final savedEmail = _prefs.getString('userEmail') ?? '';
    print('Email guardado: $savedEmail');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reauthenticate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
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

      return userData;
    } else {
      print('Error al iniciar sesión: ${response.body}');
      throw Exception('Error de login: ${response.statusCode}');
    }
  }


  Future<bool> signUp(String curp, String nombre, String role, String email, String password, String telefono,
                      String direccion, String primerApellido, String segundoApellido,) async { //<------------------- REGISTRO
    try {
      final body = jsonEncode({
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
        Uri.parse('$_baseUrl/users/'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['authToken'];
        final id = data['id'];

        await _prefs.setString('userEmail', email);
        await _prefs.setString('userId', id);

        await _secureStorage.write(key: 'authToken', value: token);
        await _secureStorage.write(key: 'userPassword', value: password);
        await _secureStorage.write(key: 'userCurp', value: curp);
        await _secureStorage.write(key: 'userName', value: nombre);
        await _secureStorage.write(key: 'userLastName1', value: primerApellido);
        await _secureStorage.write(key: 'userLastName2', value: segundoApellido);
        await _secureStorage.write(key: 'userEmail', value: email);
        await _secureStorage.write(key: 'userId', value: id);
        await _secureStorage.write(key: 'userRole', value: role);

        return true;
      } else {
        final data = jsonDecode(response.body);
        print('$data');
        throw Exception(data['error'] ?? 'Error al registrar usuario');
      }
    } catch (e) {
      rethrow; // Permite manejar el error en la UI
    }
  }


  Future<void> signOut() async { //<-------------------------------------------------------- CERRAR SESION
    final token = await _secureStorage.read(key: 'authToken');
    if (token != null) {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
    }

    await _prefs.remove('userEmail');
    await _prefs.remove('curp');
    await _secureStorage.deleteAll();
  }

  Future<String> getCurp() async {
    return await _secureStorage.read(key: 'curp') ?? '';
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'authToken') ?? '';
  }


  Future<bool> sendPasswordReset(String email) async {
    print('Correo electrónico: $email');
    try{
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
          return true;
      } else {
        throw Exception('Error al enviar el correo de recuperación');
      }

    }catch(e){
      rethrow;
    }
  }



}
