import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user.dart';

class GetUserUseCase {
  final UserRepository _repo;
  GetUserUseCase(this._repo);
  Future<User?> execute() => _repo.getUserData();
}
