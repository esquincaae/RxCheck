import '../../domain/repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  final AuthRepository _repo;
  RequestPasswordResetUseCase(this._repo);
  Future<bool> execute(String email) => _repo.sendPasswordReset(email);
}