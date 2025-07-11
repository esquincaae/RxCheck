import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_screen.dart';
import 'package:product_list_app/widgets/custom_button.dart';
import 'home_screen.dart';
import 'register_patient_screen.dart';
import 'register_medical_center_screen.dart';

class SelectModeLoginScreen extends StatefulWidget {
  @override
  _SelectModeLoginScreenState createState() => _SelectModeLoginScreenState();
}

class _SelectModeLoginScreenState extends State<SelectModeLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  String error = '';
  bool isLoading = false;

  // Nuevo estado para controlar el logo
  bool _showLogo = true;

  Future<void> loginWithCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      if (credential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Error de autenticación');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void navigateWithSlideTransition(BuildContext context, Widget page) async {

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: Padding(
        padding: const EdgeInsets.only(top: 140),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/Logo_LogRec.svg',
                  key: const ValueKey('logo_svg'),
                  height: 150,
                  placeholderBuilder: (context) =>
                  const CircularProgressIndicator(),
                  ),
                const SizedBox(height: 10),
                const Text(
                  'RxCheck',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Hero(
                  tag: 'cardHero',
                  child: Card(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                        bottom: Radius.circular(20),
                      ),
                    ),
                    margin: const EdgeInsets.only(top: 20),
                    color: Colors.white,
                    child: SizedBox(
                      width: 400,
                      height: 500,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 60, 30, 155),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Center(
                                child: Text(
                                  '¿Tienes una cuenta?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              CustomButton(
                                text: 'Iniciar Sesión',
                                onPressed: () {
                                  navigateWithSlideTransition(
                                      context, LoginScreen());
                                },
                                  minimumSize: Size(145, 30)
                              ),
                              Row(
                                children: const <Widget>[
                                  Expanded(child: Divider(color: Colors.grey)),
                                  Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      'o',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey)),
                                ],
                              ),
                              const Center(
                                child: Text(
                                  'Regístrate como:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              CustomButton(
                                text: 'Farmacéutica',
                                onPressed: () {
                                  navigateWithSlideTransition(context,
                                      RegisterMedicalCenterScreen());
                                },
                                minimumSize: Size(145, 30),
                              ),
                              CustomButton(
                                text: 'Paciente',
                                onPressed: () {
                                  navigateWithSlideTransition(context, RegisterPatientScreenPage());
                                },
                                minimumSize: const Size(145, 30),
                              ),
                            ],
                          ),
                        ),
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