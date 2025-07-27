import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final _baseUrl = dotenv.env['API_URL'];

class TwoFactorService {
  final _secureStorage = const FlutterSecureStorage();

  /// Devuelve los bytes PNG del QR
  Future<Uint8List?> setup2FA() async {
    final token = await _secureStorage.read(key: 'authToken');
    if (token == null) return null;

    final uri = Uri.parse("$_baseUrl/user/2fa/setup");
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      return response.bodyBytes;
    }
    return null;
  }

  /// Activa 2FA tras escanear el QR y recibir el código
  Future<bool> enable2FA(String code) async {
    final token = await _secureStorage.read(key: 'authToken');
    if (token == null) return false;

    final uri = Uri.parse("$_baseUrl/user/2fa/enable");
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Error al activar 2FA: ${response.statusCode} - ${response.body}");
      return false;
    }
  }

  /// Verifica un código 2FA en cualquier momento
  Future<bool> verify2FA(String code) async {
    final token = await _secureStorage.read(key: 'authToken');
    if (token == null) return false;

    final uri = Uri.parse("$_baseUrl/user/2fa/verify");
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'code': code}),
    );

    return response.statusCode == 200;
  }

  /// Deshabilita 2FA (primero verifica, luego desactiva)
  Future<bool> disable2FA(String code) async {
    // 1) Verificar
    final ok = await verify2FA(code);
    if (!ok) return false;

    // 2) Llamar al endpoint de disable
    final token = await _secureStorage.read(key: 'authToken');
    if (token == null) return false;

    final uri = Uri.parse("$_baseUrl/user/2fa/disable");
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }
}
