import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_app/screens/login_screen.dart';

void main() {
  testWidgets('Login con correo y contraseña', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    // Encuentra los campos por el texto de etiqueta
    final emailField = find.byWidgetPredicate((widget) =>
    widget is TextField && widget.decoration?.labelText == 'Correo electrónico');
    final passwordField = find.byWidgetPredicate((widget) =>
    widget is TextField && widget.decoration?.labelText == 'Contraseña');

    final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');

    // Simula ingreso de datos
    await tester.enterText(emailField, 'try@mail.com');
    await tester.enterText(passwordField, '123123');

    // Toca el botón
    await tester.tap(loginButton);
    await tester.pump();

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);
  });

  testWidgets('Login con Google', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    final googleButton = find.widgetWithText(ElevatedButton, 'Iniciar con Google');

    expect(googleButton, findsOneWidget);

    // Simula el toque
    await tester.tap(googleButton);
    await tester.pump();

    expect(googleButton, findsOneWidget);
  });

}

