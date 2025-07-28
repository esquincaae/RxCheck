import 'package:flutter/material.dart';
import '../../application/usecases/login_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _useCase;

  bool   isLoading = false;
  bool   success   = false;        // ← NUEVO
  String? error;

  LoginViewModel(this._useCase);

  Future<void> login(String email, String password) async {
    isLoading = true;
    success   = false;
    error     = null;
    notifyListeners();

    try {
      await _useCase.execute(email, password);
      success = true;              // ← para que la UI sepa que el login terminó bien
    } catch (e) {
      error   = e.toString();
      success = false;
    }

    isLoading = false;
    notifyListeners();
  }
}
