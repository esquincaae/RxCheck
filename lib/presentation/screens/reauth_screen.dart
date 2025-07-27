import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'home_screen.dart';
import 'qr_detector_screen.dart';
import 'reset_password_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class ReauthScreen extends StatefulWidget {
  final String userEmail;
  ReauthScreen({required this.userEmail});

  @override
  State<ReauthScreen> createState() => _ReauthScreenState();
}

class _ReauthScreenState extends State<ReauthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final passCtrl = TextEditingController();
  final storage = FlutterSecureStorage();
  bool isAuthenticating = false;
  String? error;

  Future<void> fingerprint() async {
    setState(() { isAuthenticating = true; error = null; });
    try {
      final authOK = await auth.authenticate(localizedReason: 'Autentícate');
      if (authOK) {
        final pwd = await storage.read(key: 'userPassword');
        if (pwd != null) {
          await context.read<LoginViewModel>().login(widget.userEmail, pwd);
          // luego navegar según rol
        }
      }
    } catch (e) {
      error = 'Error de autenticación';
    } finally {
      setState(() { isAuthenticating = false; });
    }
  }

  Future<void> withPassword() async {
    try {
      await context.read<LoginViewModel>().login(widget.userEmail, passCtrl.text.trim());
      // luego
    } catch (e) {
      setState(() { error = 'Contraseña incorrecta'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    return Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Reautenticación'),
          SizedBox(height: 12),
          ElevatedButton(onPressed: fingerprint, child: Text('Huella')),
          SizedBox(height: 12),
          TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Contraseña')),
          ElevatedButton(onPressed: withPassword, child: Text('Ingresar')),
          if (error != null) Text(error!, style: TextStyle(color: Colors.red)),
          if (vm.error != null) Text(vm.error!, style: TextStyle(color: Colors.red)),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen())), child: Text('Olvidé mi contraseña')),
        ]),
      ),
    );
  }
}
