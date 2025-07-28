import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import 'login_screen.dart';

class RegisterMedicalCenterScreen extends StatelessWidget {
  final rfcCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignupViewModel>();
    return Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(children: [
            TextField(controller: rfcCtrl, decoration: InputDecoration(labelText: 'RFC')),
            TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: 'Nombre de la Farmacia')),
            TextField(controller: telefonoCtrl, decoration: InputDecoration(labelText: 'Teléfono')),
            TextField(controller: direccionCtrl, decoration: InputDecoration(labelText: 'Dirección')),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Correo electrónico')),
            TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Contraseña')),
            TextField(controller: confirmPassCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Confirmar Contraseña')),
            SizedBox(height: 20),
            vm.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: vm.isLoading ? null : () async {
                      if (passCtrl.text != confirmPassCtrl.text) return;
                      await vm.signup(
                        rfc: rfcCtrl.text.trim(),
                        curp: '',
                        nombre: nombreCtrl.text.trim(),
                        apellidoPaterno: '',
                        apellidoMaterno: '',
                        telefono: telefonoCtrl.text.trim(),
                        direccion: direccionCtrl.text.trim(),
                        role: 'farmacia',
                        email: emailCtrl.text.trim(),
                        password: passCtrl.text.trim(),
                      );

                      if (vm.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Farmacia registrada con éxito!')),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      }
                    },
                    child: vm.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Registrar Farmacia'),
                  ),
            if (vm.error != null) Text(vm.error!, style: TextStyle(color: Colors.red)),
            TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())), child: Text('Volver a iniciar sesión')),
          ]),
        ),
      ),
    );
  }
}
