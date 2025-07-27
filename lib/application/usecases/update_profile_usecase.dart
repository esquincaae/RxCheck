import '../../domain/repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository _repo;
  UpdateProfileUseCase(this._repo);
  Future<bool> execute({required String email, required String phone, required String address}) =>
      _repo.updateProfile(email: email, phone: phone, address: address);
}
