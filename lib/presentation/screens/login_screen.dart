import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'splash_screen.dart';

class LoginScreen extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    return Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Correo electrónico')),
            SizedBox(height: 12),
            TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Contraseña')),
            SizedBox(height: 20),
            vm.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => vm.login(emailCtrl.text.trim(), passCtrl.text.trim()),
                    child: Text('Iniciar Sesión'),
                  ),
            if (vm.error != null) ...[
              SizedBox(height: 12),
              Text(vm.error!, style: TextStyle(color: Colors.red)),
            ],
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SplashScreen())), child: Text('Olvidé mi contraseña')),
          ]),
        ),
      ),
    );
  }
}
