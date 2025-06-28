import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:product_list_app/screens/login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';


class RegisterDoctorScreenPage extends StatefulWidget {
  @override
  State<RegisterDoctorScreenPage> createState() => _RegisterDoctorPageState();
}

class _RegisterDoctorPageState extends State<RegisterDoctorScreenPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  final TextEditingController nombresController = TextEditingController();
  final TextEditingController primerApellidoController = TextEditingController();
  final TextEditingController segundoApellidoController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool isLoading = false;
  String error = "";

  @override
  void dispose() {
    nombresController.dispose();
    primerApellidoController.dispose();
    segundoApellidoController.dispose();
    cedulaController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        error = '';
      });

      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim(),
        );

        final user = userCredential.user;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          error = e.message ?? 'Error al registrar';
        });
      } catch (e) {
        setState(() {
          error = 'Error inesperado: $e';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildInput({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelStyle: TextStyle(color: Colors.blue),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Color(0xFFE0E3E7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F4F8),
        title: const Text("Registro Medico"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/images/Logo_Register_Doctor.svg',
                  height: 200,
                  placeholderBuilder: (context) =>
                  const CircularProgressIndicator(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Página 1: Datos personales
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            buildInput(
                              controller: nombresController,
                              label: "Nombre(s)",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu Nombre';
                                }
                                if (value.length < 3) {
                                  return 'Debe constar de al menos 3 caracteres';
                                }
                                return null;
                              },
                            ),
                            buildInput(
                              controller: primerApellidoController,
                              label: "Primer Apellido",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu Primer Apellido';
                                }
                                if (value.length < 3) {
                                  return 'Debe constar de al menos 3 caracteres';
                                }
                                return null;
                              },
                            ),
                            buildInput(
                              controller: segundoApellidoController,
                              label: "Segundo Apellido",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu Segundo Apellido';
                                }
                                if (value.length < 3) {
                                  return 'Debe constar de al menos 3 caracteres';
                                }
                                return null;
                              },
                            ),
                            buildInput(
                              controller: cedulaController,
                              label: "CEDULA",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu CEDULA';
                                }
                                if (value.length != 18) {
                                  return 'Tu CEDULA debe constar de 7 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 16),
                              ),
                              child: const Text("Siguiente"),
                            ),
                          ],
                        ),
                        // Página 2: Datos de cuenta
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            buildInput(
                              controller: emailController,
                              label: "Correo electrónico",
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu correo';
                                }
                                if (!value.contains('@')) {
                                  return 'Ingresa un correo válido';
                                }
                                return null;
                              },
                            ),
                            buildInput(
                              controller: passController,
                              label: "Contraseña",
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña';
                                }
                                if (value.length < 8) {
                                  return 'Debe tener al menos 8 caracteres';
                                }
                                return null;
                              },
                            ),
                            buildInput(
                              controller: confirmPassController,
                              label: "Confirmar Contraseña",
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor confirma tu contraseña';
                                }
                                if (value != passController.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 16),
                                  ),
                                  child: const Text("Regresar"),
                                ),
                                isLoading
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton(
                                  onPressed: registerUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 16),
                                  ),
                                  child: const Text("Registrarse"),
                                ),
                              ],
                            ),
                            if (error.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(error,
                                    style: const TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
