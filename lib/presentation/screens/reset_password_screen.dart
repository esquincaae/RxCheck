import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/reset_password_viewmodel.dart';

class ResetPasswordScreen extends StatelessWidget {
  final emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext ctx) {
    final vm = ctx.watch<ResetPasswordViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar contraseña')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Correo')),
          SizedBox(height: 20),
          vm.isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => vm.sendCode(emailCtrl.text.trim()),
                child: Text('Enviar código'),
              ),
          if (vm.message != null) ...[
            SizedBox(height: 12),
            Text(vm.message!, style: TextStyle(color: Colors.green)),
          ],
          TextButton(
            onPressed: () => Navigator.pushNamed(ctx, '/confirm'),
            child: Text('Ya tengo código'),
          ),
        ]),
      ),
    );
  }
}