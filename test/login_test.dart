import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:RxCheck/screens/login_screen.dart';
import 'package:RxCheck/widgets/custom_input_field.dart';
import 'package:RxCheck/widgets/custom_button.dart';

void main() {
  testWidgets('LoginScreen muestra elementos estáticos correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
          home: LoginScreen(),
        );
        }
      ),
    );

    await tester.pumpAndSettle();

    final inputFieldsFinder = find.byType(CustomInputField);
    expect(inputFieldsFinder, findsNWidgets(2));

    final buttonFinder = find.byType(CustomButton);
    expect(buttonFinder, findsOneWidget);

    final buttonTextFinder = find.descendant(
      of: buttonFinder,
      matching: find.text('Iniciar Sesión'),
    );
    expect(buttonTextFinder, findsOneWidget);

    final titleFinder = find.text('Iniciar Sesión');
    expect(titleFinder, findsWidgets);

    await tester.tap(buttonFinder);
    await tester.pump();

  });
}
