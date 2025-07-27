import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import 'login_screen.dart';

class RegisterPatientScreen extends StatelessWidget {
  final curpCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final apellidoPaternoCtrl = TextEditingController();
  final apellidoMaternoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final addrCtrl = TextEditingController();
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
            TextField(controller: curpCtrl, decoration: InputDecoration(labelText: 'CURP')),
            TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: 'Nombre')),
            TextField(controller: apellidoPaternoCtrl, decoration: InputDecoration(labelText: 'Primer Apellido')),
            TextField(controller: apellidoMaternoCtrl, decoration: InputDecoration(labelText: 'Segundo Apellido')),
            TextField(controller: telefonoCtrl, decoration: InputDecoration(labelText: 'Teléfono')),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Correo electrónico')),
            TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Contraseña')),
            TextField(controller: confirmPassCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Confirmar Contraseña')),
            SizedBox(height: 20),
            vm.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      if (passCtrl.text != confirmPassCtrl.text) return;
                      vm.signup(
                        rfc: '',
                        curp: curpCtrl.text.trim(),
                        nombre: nombreCtrl.text.trim(),
                        apellidoPaterno: apellidoPaternoCtrl.text.trim(),
                        apellidoMaterno: apellidoMaternoCtrl.text.trim(),
                        telefono: telefonoCtrl.text.trim(),
                        direccion: addrCtrl.text.trim(),
                        role: 'paciente',
                        email: emailCtrl.text.trim(),
                        password: passCtrl.text.trim(),
                      );
                    },
                    child: Text('Registrar Paciente'),
                  ),
            if (vm.error != null) Text(vm.error!, style: TextStyle(color: Colors.red)),
            TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())), child: Text('Volver a iniciar sesión')),
          ]),
        ),
      ),
    );
  }
}
