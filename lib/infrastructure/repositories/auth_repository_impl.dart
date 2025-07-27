import 'dart:convert';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/http_auth_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final HttpAuthDataSource _ds;
  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(this._ds, this._storage, this._prefs);

  @override
  Future<bool> signIn(String email, String password) async {
    final resp = await _ds.login(email, password);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body)['data'];
      await _storage.write(key: 'authToken', value: data['access_token']);
      await _prefs.setString('curp', data['user']['curp']);
      await _prefs.setString('nombre', data['user']['nombre']);
      await _prefs.setString('role', data['user']['role']);
      return true;
    }
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Login failed');
  }

  @override
  Future<bool> signUp({
    required String rfc,
    required String curp,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
    required String direccion,
    required String role,
    required String email,
    required String password,
  }) async {
    final body = {
      'rfc': rfc,
      'curp': curp,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'telefono': telefono,
      'domicilio': direccion,
      'role': role,
      'email': email,
      'password': password,
    };
    final resp = await _ds.register(body);
    if (resp.statusCode == 200 || resp.statusCode == 201) return true;
    final msg = jsonDecode(resp.body)['message'] ?? 'Register failed';
    throw Exception(msg);
  }

  @override
  Future<void> signOut() async {
    final token = await _storage.read(key: 'authToken');
    if (token != null) await _ds.logout(token);
    await _storage.deleteAll();
    await _prefs.clear();
  }

  @override
  Future<bool> sendPasswordReset(String email) async {
    final resp = await _ds.requestPasswordReset(email);
    return resp.statusCode == 201;
  }

  @override
  Future<bool> confirmPasswordReset(String email, String code, String newPassword) async {
    final resp = await _ds.confirmPasswordReset(email, code, newPassword);
    if (resp.statusCode == 201) return true;
    throw Exception('Error al confirmar el cambio de contraseña');
  }

  @override
  Future<void> deleteAccount() async {
    final curp = await _prefs.getString('curp');
    if (curp == null) throw Exception('No curp');
    final resp = await _ds.deleteAccount(curp);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Error al eliminar cuenta');
    }
    await _storage.deleteAll();
    await _prefs.clear();
  }
}
