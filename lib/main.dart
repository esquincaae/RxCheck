import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:local_auth/local_auth.dart';

import 'screens/reauth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/select_mode_login_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/qr_detector_screen.dart';

// Permite navegar desde fuera del árbol de widgets
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
  runApp(
      ScreenUtilInit(
          designSize: Size(390, 844),
          minTextAdapt: true,
          builder: (context, child) => MyApp(),
      child: MyApp(),
      ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
  }

  @override
  Widget build(BuildContext context) {
    return SessionTimeoutHandler(
      child: MaterialApp(                                       //MAterial APP
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Recetas Medicas',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: AuthWrapper(),
      ),
    );
  }
}

/// Controla si mostrar login, reautenticación o home según sesión y biometría
class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _handleAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SelectModeLoginScreen()),
      );
    } else {
      bool didAuthenticate = false;
      try {
        didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Autentícate para continuar',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );
      } catch (e) {
        print('Error en autenticación local: $e');
      }

      if (didAuthenticate) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        final email = user.email ?? '';
        //await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ReauthScreen(userEmail: email)),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// Escucha si el usuario toca la pantalla y reinicia el temporizador de sesión
class SessionTimeoutHandler extends StatefulWidget {
  final Widget child;
  const SessionTimeoutHandler({required this.child, Key? key}) : super(key: key);

  @override
  State<SessionTimeoutHandler> createState() => _SessionTimeoutHandlerState();
}

class _SessionTimeoutHandlerState extends State<SessionTimeoutHandler> with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Duration timeoutDuration = Duration(hours: 5);

  void _startTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(timeoutDuration, _handleSessionTimeout);
  }

  void _handleSessionTimeout() async {
    await FirebaseAuth.instance.signOut();
    await _storage.deleteAll();
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SelectModeLoginScreen()),
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleUserInteraction,
      onPanDown: _handleUserInteraction,
      child: widget.child,
    );
  }
}
