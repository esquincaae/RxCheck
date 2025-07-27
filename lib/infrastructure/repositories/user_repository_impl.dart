import 'dart:convert';
import 'dart:io';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasource/http_user_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepositoryImpl implements UserRepository {
  final HttpUserDataSource _ds;
  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;

  UserRepositoryImpl(this._ds, this._storage, this._prefs);

  Future<String> _token() async => await _storage.read(key: 'authToken') ?? '';
  String? _curp() => _prefs.getString('curp');

  @override
  Future<User?> getUserData() async {
    final curp = _curp();
    final token = await _token();
    if (curp == null || token.isEmpty) return null;
    final resp = await _ds.getUser(token, curp);
    if (resp.statusCode == 200) {
      final d = jsonDecode(resp.body)['data'];
      return User(
        curp: d['curp'] ?? '',
        nombre: d['nombre'] ?? '',
        apellidoPaterno: d['apellidoPaterno'] ?? '',
        apellidoMaterno: d['apellidoMaterno'] ?? '',
        email: d['email'] ?? '',
        telefono: d['telefono'] ?? '',
        direccion: d['domicilio'] ?? '',
        role: d['role'] ?? '',
        imagen: d['imagen'] ?? '',
      );
    }
    return null;
  }

  @override
  Future<bool> updateImage(File imageFile) async {
    final curp = _curp();
    final token = await _token();
    if (curp == null || token.isEmpty) return false;
    final resp = await _ds.updateImage(token, curp, imageFile);
    if (resp.statusCode == 200) return true;
    return false;
  }

  @override
  Future<bool> updateProfile({required String email, required String phone, required String address}) async {
    final curp = _curp();
    final token = await _token();
    if (curp == null || token.isEmpty) return false;
    final resp = await _ds.updateProfile(token, curp, {
      'email': email,
      'telefono': phone,
      'domicilio': address,
    });
    return resp.statusCode == 200;
  }
}
