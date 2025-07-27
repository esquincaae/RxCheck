import '../entities/user.dart';
import 'dart:io';

abstract class UserRepository {
  Future<User?> getUserData();
  Future<bool> updateProfile({required String email, required String phone, required String address});
  Future<bool> updateImage(File imageFile);
}
