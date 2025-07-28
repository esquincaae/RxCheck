import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:RxCheck/screens/reset_password_screen.dart';

void main() {
  testWidgets('ResetPasswordScreen muestra widgets y valida email', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResetPasswordScreen(),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);

    final sendButton = find.text('enviar codigo');
    expect(sendButton, findsOneWidget);

    await tester.tap(sendButton);
    await tester.pump();

    expect(find.text('Por favor ingresa tu correo'), findsOneWidget);

    final emailField = find.byType(TextFormField);
    await tester.enterText(emailField, 'correo-invalido');
    await tester.tap(sendButton);
    await tester.pump();

    expect(find.text('Ingresa un correo válido'), findsOneWidget);

    await tester.enterText(emailField, 'test@example.com');
    await tester.tap(sendButton);
    await tester.pump();

    expect(find.text('Por favor ingresa tu correo'), findsNothing);
    expect(find.text('Ingresa un correo válido'), findsNothing);
  });
}
