import 'package:flutter/material.dart';
import '../../application/usecases/login_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _useCase;
  bool isLoading = false;
  String? error;

  LoginViewModel(this._useCase);

  Future<void> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _useCase.execute(email, password);
      // navegar a Home o QR según rol
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
