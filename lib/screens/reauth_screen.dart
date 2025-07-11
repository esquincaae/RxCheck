import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:product_list_app/services/auth_service.dart';

import 'home_screen.dart';
import 'recover_password_screen.dart';
import 'package:product_list_app/widgets/styles.dart';
import 'package:product_list_app/widgets/custom_button.dart';
import 'package:product_list_app/widgets/custom_input_field.dart';

//Refactorizado :)


class ReauthScreen extends StatefulWidget {
  final String userEmail;

  const ReauthScreen({super.key, required this.userEmail});

  @override
  State<ReauthScreen> createState() => _ReauthScreenState();
}

class _ReauthScreenState extends State<ReauthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _passwordController = TextEditingController();
  late PageController _pageController;
  String error = '';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      error = '';
    });

    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Por favor, autentícate para continuar',
        options: const AuthenticationOptions(biometricOnly: false),
      );

      if (authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {

        setState(() => error = 'No fue posible autenticarse');

      }
    } catch (e) {
      setState(() => error = 'Error en autenticación: $e');
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _validatePassword() async {
    String enteredPassword = _passwordController.text.trim();

    setState(() {
      String? error = '';// limpia errores previos
    });

    try {
      // Usa AuthService para reautenticación real
      await AuthService().reauthenticate(widget.userEmail, enteredPassword);

      // Si no lanza error, autenticación exitosa
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      setState(() {
        error = '';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(text: widget.userEmail);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/images/Logo_LogRec.svg',
                height: 145.h,
                placeholderBuilder: (_) =>
                    CircularProgressIndicator(color: AppColors.primary),
              ),
              SizedBox(height: 20.h),
              Text(
                'Iniciar Sesión',
                style: AppTextStyles.logo,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                decoration: AppDecorations.card,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300.h,
                    minHeight: 250.h,
                  ),
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSelectionPage(emailController),
                      _buildPasswordPage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionPage(TextEditingController emailController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomInputField(
          label: 'Email',
          controller: emailController,
          isDisabled: true,
          icon: Icons.email_outlined,
        ),
        SizedBox(height: 20.h),
        if (_isAuthenticating)
          CircularProgressIndicator(color: AppColors.primary)
        else
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  icon: const Icon(Icons.password_outlined),
                  text: 'Contraseña',
                  onPressed: () {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  borderRadius: 15.r,
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomButton(
                  icon: const Icon(Icons.fingerprint_outlined),
                  text: 'Huella',
                  onPressed: _authenticate,
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  borderRadius: 15.r,
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
                ),
              ),
            ],
          ),
        SizedBox(height: 25.h),
        if (error.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              error,
              style: AppTextStyles.error,
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(height: 25.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Olvidaste tu contraseña?',
              style: AppTextStyles.defaultText,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RecoverPasswordScreen()),
                );
              },
              child: Text(
                'Presiona Aquí',
                style: AppTextStyles.linkText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            },
          ),
        ),
        SizedBox(height: 10.h),
        CustomInputField(
          label: 'Contraseña',
          controller: _passwordController,
          obscureText: true,
          icon: Icons.lock_outline,
        ),
        SizedBox(height: 15.h),
        CustomButton(
          text: 'Iniciar Sesión',
          onPressed: _validatePassword,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          borderRadius: 15.r,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        ),
        SizedBox(height: 15.h),
        if (error.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              error,
              style: AppTextStyles.error,
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(height: 30.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Olvidaste tu contraseña?',
              style: AppTextStyles.defaultText,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RecoverPasswordScreen()),
                );
              },
              child: Text(
                'Presiona Aquí',
                style: AppTextStyles.linkText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
