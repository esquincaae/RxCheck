abstract class AuthRepository {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp({
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
  });
  Future<void> signOut();
  Future<bool> sendPasswordReset(String email);
  Future<bool> confirmPasswordReset(String email, String code, String newPassword);
  Future<void> deleteAccount();
}
