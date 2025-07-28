import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../viewmodels/login_viewmodel.dart';
import 'home_screen.dart';
import 'qr_detector_screen.dart';

class LoginScreen extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 24),

              // Botón de inicio de sesión
              vm.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        await vm.login(emailCtrl.text.trim(), passCtrl.text.trim());
                        if (vm.success) {
                          final prefs = await SharedPreferences.getInstance();
                          final role  = prefs.getString('role');
                          if (role == 'paciente') {
                            Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => HomeScreen()));
                          } else if (role == 'farmacia') {
                            Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => QRDetectorScreen()));
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Acceso denegado'),
                                content: const Text('Tu cuenta no tiene permisos para usar esta app.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cerrar'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Iniciar Sesión'),
                    ),

              // Aquí agregamos el botón “Olvidé mi contraseña”
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Asume que tienes una ruta '/reset' configurada en tu MaterialApp
                  Navigator.pushNamed(context, '/reset');
                },
                child: const Text('¿Olvidaste tu contraseña?'),
              ),

              if (vm.error != null) ...[
                const SizedBox(height: 12),
                Text(vm.error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
