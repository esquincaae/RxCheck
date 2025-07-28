import 'package:flutter/material.dart';
import '../../application/usecases/confirm_password_reset_usecase.dart';

class ConfirmPasswordViewModel extends ChangeNotifier {
  final ConfirmPasswordResetUseCase _uc;
  bool isLoading = false;
  String? message;

  ConfirmPasswordViewModel(this._uc);

  Future<void> confirm(String email, String code, String newPass) async {
    isLoading = true; message = null; notifyListeners();
    try {
      await _uc.execute(email, code, newPass);
      message = 'Contraseña cambiada con éxito';
    } catch (e) {
      message = e.toString();
    } finally {
      isLoading = false; notifyListeners();
    }
  }
}