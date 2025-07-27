import 'package:flutter/material.dart';
import '../../application/usecases/get_user_usecase.dart';
import '../../application/usecases/update_profile_usecase.dart';
import '../../application/usecases/update_image_usecase.dart';
import 'dart:io';

class EditProfileViewModel extends ChangeNotifier {
  final GetUserUseCase _getUc;
  final UpdateProfileUseCase _updateUc;
  final UpdateImageUseCase _imageUc;

  bool isLoading = false;
  String? message;
  var userData;

  EditProfileViewModel(this._getUc, this._updateUc, this._imageUc);

  Future<void> loadUser() async {
    isLoading = true; notifyListeners();
    userData = await _getUc.execute();
    isLoading = false; notifyListeners();
  }

  Future<void> updateProfile(String email, String phone, String address) async {
    isLoading = true; message = null; notifyListeners();
    final success = await _updateUc.execute(email: email, phone: phone, address: address);
    message = success ? 'Perfil actualizado' : 'Error al actualizar';
    isLoading = false; notifyListeners();
  }

  Future<void> updateImage(File file) async {
    isLoading = true; message = null; notifyListeners();
    final success = await _imageUc.execute(file);
    message = success ? 'Imagen actualizada' : 'Error al subir imagen';
    if (success) await loadUser();
    isLoading = false; notifyListeners();
  }
}
