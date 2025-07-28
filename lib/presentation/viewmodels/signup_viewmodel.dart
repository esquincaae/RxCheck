import 'package:flutter/material.dart';
import '../../application/usecases/signup_usecase.dart';

class SignupViewModel extends ChangeNotifier {
  final SignupUseCase _useCase;
  bool isLoading = false;
  String? error;
  bool success = false;    // ← FLAG agregado

  SignupViewModel(this._useCase);

  Future<void> signup({
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
    isLoading = true;
    error = null;
    success = false;       // reset al iniciar
    notifyListeners();
    try {
      await _useCase.execute(
        rfc: rfc,
        curp: curp,
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        telefono: telefono,
        direccion: direccion,
        role: role,
        email: email,
        password: password,
      );
      success = true;      // marcar éxito
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
