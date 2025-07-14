class User {
  final String curp;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String email;
  final String password;
  final String telefono;
  final String direccion;
  final String role;
  final String imagen;

  User({
    required this.curp,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.email,
    required this.password,
    required this.telefono,
    required this.direccion,
    required this.role,
    required this.imagen,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      curp: json['curp'] ?? '',
      nombre: json['nombre'] ?? '',
      apellidoPaterno: json['apellidoPaterno'] ?? '',
      apellidoMaterno: json['apellidoMaterno'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      role: json['role'] ?? '',
      imagen: json['imagen'] ?? '',
    );
  }
}