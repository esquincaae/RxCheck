import '../../domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository _repo;
  SignupUseCase(this._repo);
  Future<bool> execute({
    required String rfc,
    required String curp,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String telefono,
    required String direccion,
    required String role,
    required String email,
    required String password,
  }) => _repo.signUp(
        rfc: rfc,
        curp: curp,
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        telefono: telefono,
        direccion: direccion,
        role: role,
        email: email,
        password: password,
      );
}
