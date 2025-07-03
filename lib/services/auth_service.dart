import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<UserCredential?> reauthenticate(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final credential = EmailAuthProvider.credential(email: email, password: password);
      final result = await user.reauthenticateWithCredential(credential);
      return result;
    } catch (e) {
      rethrow; // para manejar en el UI
    }
  }

  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }

  //Método para cerrar sesión y limpiar datos guardados
  Future<void> signOut() async {
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');  // borrar email recordado

    await _secureStorage.delete(key: 'userPassword');  // borrar contraseña segura
  }
}
