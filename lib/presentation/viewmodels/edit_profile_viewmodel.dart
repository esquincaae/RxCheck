import 'package:flutter/material.dart';
import '../../application/usecases/get_user_usecase.dart';
import '../../application/usecases/update_profile_usecase.dart';
import '../../application/usecases/update_image_usecase.dart';
import '../../domain/entities/user.dart';
import 'dart:io';

class EditProfileViewModel extends ChangeNotifier {
  final GetUserUseCase _getUc;
  final UpdateProfileUseCase _updateUc;
  final UpdateImageUseCase _imageUc;

  EditProfileViewModel(this._getUc, this._updateUc, this._imageUc);

  bool isLoading = false;
  String? message;
  User? user;                    // ← tipado fuerte

  Future<void> loadUser() async {
    isLoading = true;
    message   = null;
    notifyListeners();

    user = await _getUc.execute();   // puede devolver null
    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(
      {required String email, required String phone, required String address}) async {
    isLoading = true; notifyListeners();
    final ok = await _updateUc.execute(email: email, phone: phone, address: address);
    if (ok) await loadUser();      // recarga para reflejar los nuevos datos
    isLoading = false; notifyListeners();
    return ok;
  }

  Future<bool> updateImage(File file) async {
    isLoading = true; notifyListeners();
    final ok = await _imageUc.execute(file);
    if (ok) await loadUser();
    isLoading = false; notifyListeners();
    return ok;
  }
}
