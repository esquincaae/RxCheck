import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/qr_detector_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/styles.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'reset_password_screen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  String error = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void showDenegadePermision(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // evita cerrar al tocar fuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Acceso denegado'),
          content: const Text('Tu cuenta no tiene los permisos para usar esta app.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // cerrar el diálogo
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> loginWithCredentials() async {
    final authService = AuthService();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      await authService.signIn(
        emailController.text.trim(),
        passController.text.trim(),
      );

      final SharedPreferences localPrefs = await SharedPreferences.getInstance();
      final role = localPrefs.getString('role');
      if (role == 'paciente'){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }else if(role == 'farmacia'){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => QRDetectorScreen()),
        );
      }else{
        showDenegadePermision(context);
      }

    } catch (e) {
      print('$e');
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
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
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.only(top: 100.h),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/images/Logo_LogRec.svg',
                  height: 150.h,
                  placeholderBuilder: (context) =>
                  const CircularProgressIndicator(),
                ),
                SizedBox(height: 10.h),
                Text('RxCheck', style: AppTextStyles.logo),
                SizedBox(height: 20.h),
                Container(
                  decoration: AppDecorations.card,
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.all(20.w),
                  child: Form(
                    key: _formKey,
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
                        SizedBox(height: 25.h),
                        isLoading
                            ? SizedBox(
                          height: 30.h,
                          width: 30.w,
                          child: const CircularProgressIndicator(),
                        )
                            : CustomButton(
                          text: 'Iniciar Sesión',
                          onPressed: loginWithCredentials,
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          borderRadius: 20.r,
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.w, vertical: 10.h),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('¿Olvidaste tu contraseña?',
                                style: AppTextStyles.defaultText),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ResetPasswordScreen()),
                                );
                              },
                              child: Text('Presiona Aquí',
                                  style: AppTextStyles.linkText),
                            ),
                          ],
                        ),
                        if (error.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child:
                            Text(error, style: AppTextStyles.error),
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
