import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:screen_protector/screen_protector.dart';
import 'screens/register_medical_center_screen.dart';
import 'screens/register_patient_screen.dart';
import 'screens/reauth_screen.dart';
import 'screens/splash_screen.dart';
import 'services/user_service.dart';


// Permite navegar desde fuera del árbol de widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  final file = File('.env');
  print('¿Existe .env? ${await file.exists()}');
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  ]).then((_) => runApp(
      ScreenUtilInit(
        designSize: Size(390, 844),
        minTextAdapt: true,
        builder: (context, child) => MyApp(),
        child: MyApp(),
      ),
    )
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
    checkUserLogin();
  }

  Future<void> checkUserLogin() async {
    final storage = FlutterSecureStorage();
    final email = await storage.read(key: 'userEmail');

    setState(() {
      isUserLoggedIn = email != null && email.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Recetas Medicas',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFF1F4F8),
          foregroundColor: Colors.black,
        ),
        scaffoldBackgroundColor: Color(0xFFF1F4F8),
        progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.blue),
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
    );

    return isUserLoggedIn
        ? SessionTimeoutHandler(child: app)
        : app;
  }
}

/// Controla si mostrar reautenticación o la vista de seleccion
class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

// Devuelve un Map con info de usuario, o null si no hay
  Future<Map<String, String>> _getUserData() async {
    final _userService = UserService();
    final userData = await _secureStorage.readAll();
    final curp = userData['curp'] ?? '';
    bool curpExist = await _userService.getUserByCurpExists(curp);
    await _secureStorage.write(key: 'curpExist', value: curpExist.toString());
    return userData;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        final user = snapshot.data!;
        final userEmail = user['userEmail'] ?? '';
        final isLoggedIn = (userEmail != null && userEmail.isNotEmpty && userEmail != '');
        final curpExist = user['curpExist'] ?? '';
        if (curpExist != false){
          if (isLoggedIn) {
            return ReauthScreen(userEmail: userEmail);

          } else {
            return SplashScreen();
          }
        }else{
          return SplashScreen();
        }
      },
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
  final Duration timeoutDuration = Duration(minutes: 30);

  void _startTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(timeoutDuration, _handleSessionTimeout);
  }

  void _handleSessionTimeout() async {
    final userEmail = await _storage.read(key: 'userEmail') ?? '';
    print('Timeout triggered. userEmail = $userEmail');
    if (userEmail.isEmpty || userEmail == '') {
      return;
    }

    final currentContext = navigatorKey.currentContext;
    if (currentContext != null) {
      final currentWidget = ModalRoute.of(currentContext)?.settings.name;
      if (currentWidget == '/reauth' || currentWidget == '/splash' || currentWidget == '/register_patient' || currentWidget == '/register_medical_center') {
        return;
      }
    }

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
            settings: RouteSettings(name: '/reauth'),
            builder: (_) => ReauthScreen(userEmail: userEmail),
        ),
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
