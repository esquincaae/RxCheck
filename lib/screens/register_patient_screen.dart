import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:product_list_app/screens/login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:product_list_app/widgets/custom_input_field.dart';

//Refactorizado :))
class RegisterPatientScreenPage extends StatefulWidget {
  @override
  State<RegisterPatientScreenPage> createState() => _RegistroPacientePageState();
}

class _RegistroPacientePageState extends State<RegisterPatientScreenPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  final TextEditingController nombresController = TextEditingController();
  final TextEditingController primerApellidoController = TextEditingController();
  final TextEditingController segundoApellidoController = TextEditingController();
  final TextEditingController curpController = TextEditingController();
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
    curpController.dispose();
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

  // Estilos y tamaños responsivos centralizados
  late double screenWidth;
  late double screenHeight;
  late double basePadding;
  late double baseFontSize;
  late double buttonVerticalPadding;
  late double buttonHorizontalPadding;

  static const Color backgroundColor = Color(0xFFF1F4F8);
  static const Color primaryColor = Colors.blue;
  static const Color cardColor = Colors.white;
  static const Color errorColor = Colors.red;

  final BorderRadius cardBorderRadius = BorderRadius.circular(20);
  final BorderRadius buttonBorderRadius = BorderRadius.circular(20);

  TextStyle getTitleTextStyle() =>
      TextStyle(fontSize: baseFontSize * 1.5, fontWeight: FontWeight.bold);

  ButtonStyle getButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
    padding: EdgeInsets.symmetric(
        horizontal: buttonHorizontalPadding, vertical: buttonVerticalPadding),
  );

  EdgeInsets getCardPadding() => EdgeInsets.fromLTRB(
      basePadding * 1.5, basePadding * 3, basePadding * 1.5, 0);

  EdgeInsets getScreenPadding() => EdgeInsets.only(top: screenHeight * 0.12);

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    basePadding = screenWidth * 0.04; // 4% ancho pantalla
    baseFontSize = screenWidth * 0.05; // 5% ancho pantalla para base font size
    buttonVerticalPadding = basePadding * 0.8;
    buttonHorizontalPadding = basePadding * 3;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: getScreenPadding(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/images/Logo_Register_Patient.svg',
                height: screenHeight * 0.18,
                placeholderBuilder: (context) =>
                const CircularProgressIndicator(),
              ),
              SizedBox(height: basePadding / 2),
              Text(
                'Registro Paciente',
                style: getTitleTextStyle(),
              ),
              SizedBox(height: basePadding / 2),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: cardBorderRadius),
                  margin: EdgeInsets.symmetric(
                      horizontal: basePadding * 0.8, vertical: basePadding * 1.2),
                  color: cardColor,
                  child: Padding(
                    padding: getCardPadding(),
                    child: Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Página 1: Datos personales
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                SizedBox(height: basePadding / 2),
                                CustomInputField(
                                  controller: nombresController,
                                  label: "Nombre(s)",
                                  icon: Icons.person_outline_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu nombre';
                                    }
                                    if (value.length < 3) {
                                      return 'Debe constar de al menos 3 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                CustomInputField(
                                  controller: primerApellidoController,
                                  label: "Primer Apellido",
                                  icon: Icons.person_outline_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese su Primer Apellido';
                                    }
                                    if (value.length < 3) {
                                      return 'Debe constar de al menos 3 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                CustomInputField(
                                  controller: segundoApellidoController,
                                  label: "Segundo Apellido",
                                  icon: Icons.person_outline_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese su Segundo Apellido';
                                    }
                                    if (value.length < 3) {
                                      return 'Debe constar de al menos 3 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                CustomInputField(
                                  controller: curpController,
                                  label: "CURP",
                                  icon: Icons.perm_identity_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese su CURP';
                                    }
                                    if (value.length != 18) {
                                      return 'Debe constar de 18 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: basePadding * 1.5),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.ease,
                                      );
                                    }
                                  },
                                  style: getButtonStyle(),
                                  child: const Text("Siguiente"),
                                ),
                                SizedBox(height: basePadding),
                              ],
                            ),
                          ),

                          // Página 2: Datos de cuenta
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () {
                                      _pageController.previousPage(
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.ease,
                                      );
                                    },
                                  ),
                                ),
                                CustomInputField(
                                  controller: emailController,
                                  label: "Correo electrónico",
                                  icon: Icons.email_outlined,
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
                                CustomInputField(
                                  controller: passController,
                                  label: "Contraseña",
                                  icon: Icons.lock_outline_rounded,
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
                                CustomInputField(
                                  controller: confirmPassController,
                                  label: "Confirmar Contraseña",
                                  icon: Icons.lock_outline_rounded,
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
                                SizedBox(height: basePadding * 1.5),
                                isLoading
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton(
                                  onPressed: registerUser,
                                  style: getButtonStyle(),
                                  child: const Text("Registrarse"),
                                ),
                                if (error.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: basePadding),
                                    child: Text(error,
                                        style: TextStyle(color: errorColor)),
                                  ),
                                SizedBox(height: basePadding),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

