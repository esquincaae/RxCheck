import 'package:flutter/material.dart';
import '../../application/usecases/request_password_reset_usecase.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final RequestPasswordResetUseCase _uc;
  bool isLoading = false;
  String? message;

  ResetPasswordViewModel(this._uc);

  Future<void> sendCode(String email) async {
    isLoading = true; message = null; notifyListeners();
    try {
      await _uc.execute(email);
      message = 'Si el correo existe, llegarás un código.';
    } catch (e) {
      message = e.toString();
    } finally {
      isLoading = false; notifyListeners();
    }
  }
}