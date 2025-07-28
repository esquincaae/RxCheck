import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/confirm_password_viewmodel.dart';

class ConfirmPasswordScreen extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext ctx) {
    final vm = ctx.watch<ConfirmPasswordViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text('Confirmar contraseña')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Correo')),
          TextField(controller: codeCtrl, decoration: InputDecoration(labelText: 'Código')),
          TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Nueva contraseña')),
          SizedBox(height: 20),
          vm.isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => vm.confirm(
                  emailCtrl.text.trim(),
                  codeCtrl.text.trim(),
                  passCtrl.text.trim(),
                ),
                child: Text('Confirmar'),
              ),
          if (vm.message != null) ...[
            SizedBox(height: 12),
            Text(vm.message!, style: TextStyle(color: vm.message!.contains('éxito') ? Colors.green : Colors.red)),
          ],
        ]),
      ),
    );
  }
}