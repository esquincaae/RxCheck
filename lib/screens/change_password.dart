import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_input_field.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  bool isLoading = false;
  String message = '';

  Future<void> confirmPasswordReset() async {
    if (!_formKey.currentState!.validate())

      setState(() {
        isLoading = true;
        message = '';
      });

    try {
      await AuthService().ConfirmPasswordReset(
        emailController.text.trim(),
        codeController.text.trim(),
        newPasswordController.text.trim(),
      );
      setState(() {
        message = 'Contraseña cambiada con exito';
      });
    } catch (e) {
      setState(() {
        message = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      body: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/Logo_recover_password.svg',
                  height: 150,
                  placeholderBuilder: (context) => const CircularProgressIndicator(),
                ),
                SizedBox(height: 10),
                Text(
                  'Cambiar Contraseña',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.only(top: 20, left: 24, right: 24),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                          SizedBox(height: 6),
                          CustomInputField(
                            controller: emailController,
                            label: "Correo electrónico",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu correo';
                              }
                              if (!value.contains('@') && !value.contains('.')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 6),
                          CustomInputField(
                            controller: codeController,
                            label: "Codigo de seguridad",
                            toUpperCase: true,
                            icon: Icons.code_outlined,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el codigo que se envio a su correo ingresado en la vista anterior';
                              }
                              if (value.length < 6 || value.length > 6) {
                                return 'Ingresa un codigo valido';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 6),
                          CustomInputField(
                            controller: newPasswordController,
                            label: "Nueva contraseña",
                            icon: Icons.password_outlined,
                            obscureText: true,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su nueva contraseña';
                              }
                              if (value.length < 8) {
                                return 'Debe tener al menos 8 caracteres';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 6),
                          isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                            onPressed: confirmPasswordReset,
                            child: Text('Recuperar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          SizedBox(height: 12),
                          if (message.isNotEmpty)
                            Text(
                              message,
                              style: TextStyle(
                                color: message.contains('exito') ? Colors.green : Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => LoginScreen()),
                              );
                            },
                            child: Text(
                              'Volver a iniciar sesión',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
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