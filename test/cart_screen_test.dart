import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Duration sessionTimeout = const Duration(minutes: 5);

  /// Guarda el token y la última hora de actividad
  Future<void> saveSessionData(String token) async {
    final now = DateTime.now().toIso8601String();
    await _secureStorage.write(key: 'token', value: token);
    await _secureStorage.write(key: 'last_active_time', value: now);
  }

  /// Limpia el token y hora almacenados
  Future<void> clearSessionData() async {
    await _secureStorage.delete(key: 'token');
    await _secureStorage.delete(key: 'last_active_time');
  }

  /// Verifica si el usuario ha estado inactivo por más de X minutos
  Future<bool> isSessionExpired() async {
    final lastActive = await _secureStorage.read(key: 'last_active_time');
    if (lastActive == null) return true;
    final lastTime = DateTime.tryParse(lastActive);
    if (lastTime == null) return true;

    final diff = DateTime.now().difference(lastTime);
    return diff > sessionTimeout;
  }

  /// Redirige al login si la sesión ha expirado
  Future<void> validateSession(GlobalKey<NavigatorState> navigatorKey) async {
    final expired = await isSessionExpired();
    if (expired) {
      await clearSessionData();
      navigatorKey.currentState?.pushReplacementNamed('/login');
    }
  }
}
