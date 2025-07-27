import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_patient_screen.dart';
import 'register_medical_center_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('RxCheck', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 24),
          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen())), child: Text('Iniciar Sesión')),
          SizedBox(height: 12),
          Text('o'),
          SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterMedicalCenterScreen())), child: Text('Registrar Farmacia')),
          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPatientScreen())), child: Text('Registrar Paciente')),
        ]),
      ),
    );
  }
}
