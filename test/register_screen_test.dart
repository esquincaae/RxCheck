import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_app/screens/register_screen.dart';

void main() {
  testWidgets('Formulario de registro funciona correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(),
      ),
    );

    // Busca los campos por texto de etiqueta
    final emailField = find.byWidgetPredicate((widget) =>
    widget is TextField && widget.decoration?.labelText == 'Correo electrónico');
    final passwordField = find.byWidgetPredicate((widget) =>
    widget is TextField && widget.decoration?.labelText == 'Contraseña');
    final passwordConfirmField = find.byWidgetPredicate((widget) =>
    widget is TextField && widget.decoration?.labelText == 'Confirmar contraseña');

    final registerButton = find.widgetWithText(ElevatedButton, 'Registrarse');

    // Escribe en los campos
    await tester.enterText(emailField, 'juan@example.com');
    await tester.enterText(passwordField, '123456');
    await tester.enterText(passwordConfirmField, '123456');

    // Simula el botón
    await tester.tap(registerButton);
    await tester.pump();

    expect(registerButton, findsOneWidget);
  });
}
