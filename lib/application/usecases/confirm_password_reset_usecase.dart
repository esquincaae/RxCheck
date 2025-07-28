import '../../domain/repositories/auth_repository.dart';

class ConfirmPasswordResetUseCase {
  final AuthRepository _repo;
  ConfirmPasswordResetUseCase(this._repo);
  Future<bool> execute(String email, String code, String newPassword) =>
      _repo.confirmPasswordReset(email, code, newPassword);
}