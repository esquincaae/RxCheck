import '../../domain/repositories/user_repository.dart';
import 'dart:io';

class UpdateImageUseCase {
  final UserRepository _repo;
  UpdateImageUseCase(this._repo);
  Future<bool> execute(File file) => _repo.updateImage(file);
}
