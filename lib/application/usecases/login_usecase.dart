import '../../domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);
  Future<bool> execute(String email, String password) => _repo.signIn(email, password);
}
