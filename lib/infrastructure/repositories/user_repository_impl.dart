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
  String? _curp()   => _prefs.getString('curp');
  String? _nombre() => _prefs.getString('nombre');
  String? _email()  => _prefs.getString('userEmail');
  Future<String?> _pass() => _storage.read(key: 'userPassword');

  @override
  Future<User?> getUserData() async {
    final curp  = _prefs.getString('curp');
    final token = await _storage.read(key: 'authToken') ?? '';
    if (curp == null || token.isEmpty) return null;

    // DEBUG: imprime status y cuerpo
    final resp = await _ds.getUser(token, curp);
    print('GET /users/$curp → ${resp.statusCode} ${resp.body}');
    if (resp.statusCode != 200) return null;

    final json = jsonDecode(resp.body);
    final d = json['data'] ?? json;
    return User(
      curp:            d['curp'] ?? '',
      nombre:          d['nombre'] ?? '',
      apellidoPaterno: d['apellidoPaterno'] ?? '',
      apellidoMaterno: d['apellidoMaterno'] ?? '',
      email:           d['email'] ?? '',
      telefono:        d['telefono'] ?? '',
      direccion:       d['domicilio'] ?? '',
      role:            d['role'] ?? '',
      imagen:          d['imagen'] ?? '',
    );
  }

  @override
  Future<bool> updateProfile({
    required String email,
    required String phone,
    required String address,
  }) async {
    final curp  = _curp();
    final token = await _token();
    final pass  = await _pass() ?? 'password';
    final nombre = _nombre() ?? '';

    if (curp == null || token.isEmpty) return false;

    // Incluye password para no pisarlo
    final fields = {
      'nombre'   : nombre,
      'curp'     : curp,
      'email'    : email,
      'telefono' : phone,
      'domicilio': address,
      'password' : pass,
    };

    final resp = await _ds.updateProfile(token, curp, fields);
    final ok   = resp.statusCode == 200 || resp.statusCode == 201;
    if (!ok) {
      final body = await resp.stream.bytesToString();
      print('updateProfile error: ${resp.statusCode} → $body');
    }
    return ok;
  }

  @override
  Future<bool> updateImage(File imageFile) async {
    final token   = await _token();
    final curp    = _curp();
    final nombre  = _prefs.getString('nombre') ?? '';
    final email   = _prefs.getString('email')  ?? '';

    if (token.isEmpty || curp == null) return false;

    final resp = await _ds.updateImage(
      token,
      curp,
      imageFile,
      extraFields: {
        'nombre': nombre,
        'curp'  : curp,
        'email' : email,
      },
    );

    final ok = resp.statusCode == 200 || resp.statusCode == 201;
    if (!ok) {
      final body = await resp.stream.bytesToString();
      print('updateImage error: ${resp.statusCode} → $body');
    }
    return ok;
  }
}