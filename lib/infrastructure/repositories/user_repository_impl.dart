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
      final decoded = jsonDecode(resp.body);
      // si tu API no anida bajo "data", toma el objeto completo:
      final d = decoded['data'] ?? decoded;
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
    Future<bool> updateProfile({
      required String email,
      required String phone,
      required String address,
    }) async {
      final curp  = _curp();
      final token = await _token();
      if (curp == null || token.isEmpty) return false;

      // Obtén el usuario actual para reutilizar todos sus campos
      final existing = await getUserData();
      if (existing == null) return false;

      final resp = await _ds.updateProfile(token, curp, {
        'curp'            : existing.curp,
        'nombre'          : existing.nombre,
        'apellidoPaterno' : existing.apellidoPaterno,
        'apellidoMaterno' : existing.apellidoMaterno,
        'email'           : email,
        'telefono'        : phone,
        'domicilio'       : address,
      });

      final ok = resp.statusCode == 200 || resp.statusCode == 201;
      if (!ok) {
        final body = await resp.stream.bytesToString();
        print('updateProfile error: ${resp.statusCode} -> $body');
      }
      return ok;
    }

  @override
  Future<bool> updateImage(File imageFile) async {
    final curp  = _curp();
    final token = await _token();
    if (curp == null || token.isEmpty) return false;

    final resp  = await _ds.updateImage(token, curp, imageFile);
    final ok    = resp.statusCode == 200 || resp.statusCode == 201;

    if (!ok) {
      final body = await resp.stream.bytesToString();
      print('updateImage error: ${resp.statusCode} -> $body');
    }
    return ok;
  }
}
