import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

//Permite navegar desde fuera del árbol de widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBAGkqMTLM8WgYH-NdNHM8Ijm0B45fPbCg",
      appId: "1:70532459459:android:6ee84cc4ae5a8894316b76",
      messagingSenderId: "70532459459",
      projectId: "usuariosfakestoreapi",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SessionTimeoutHandler( //para monitorear toda la app con el detector de actividad
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Gestor de Productos',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return LoginScreen();
    } else {
      return HomeScreen();
    }
  }
}

//escucha si el usuario toca la pantalla,
class SessionTimeoutHandler extends StatefulWidget {
  final Widget child;
  const SessionTimeoutHandler({required this.child, Key? key}) : super(key: key);

  @override
  State<SessionTimeoutHandler> createState() => _SessionTimeoutHandlerState();
}

class _SessionTimeoutHandlerState extends State<SessionTimeoutHandler> with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  final Duration timeoutDuration = Duration(seconds: 5);

  void _startTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(timeoutDuration, _handleSessionTimeout);
  }

  void _handleSessionTimeout() async {
    await FirebaseAuth.instance.signOut();  //cierra sesión actual
    await _storage.deleteAll();             //elimina los datos sensibles almacenados
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()), //abre la vista de login al ser llamado
            (route) => false,
      );
    }
  }

  void _handleUserInteraction([_]) {
    _startTimer();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //Pausa sesion cuando la app esta en segundo plano
  // y resume cuando vuelve al frente
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _handleSessionTimeout();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(         //detecta gestos y reinicia el timer
      behavior: HitTestBehavior.translucent,
      onTap: _handleUserInteraction,
      onPanDown: _handleUserInteraction,
      child: widget.child,
    );
  }
}
