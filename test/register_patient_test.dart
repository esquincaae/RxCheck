import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:RxCheck/screens/register_patient_screen.dart';

void main() {
  testWidgets('RegisterPatientScreenPage muestra elementos estáticos correctamente',
          (WidgetTester tester) async {

        final testWidget = MediaQuery(
          data: const MediaQueryData(
            size: Size(800, 1200),
          ),
          child: MaterialApp(
            home: RegisterPatientScreenPage(),
          ),
        );

        await tester.pumpWidget(testWidget);

        expect(find.text('Registro Paciente'), findsOneWidget);

        expect(find.text('Siguiente'), findsOneWidget);

        expect(find.text('Registrarse'), findsNothing);

        expect(find.byType(SvgPicture), findsOneWidget);

        expect(find.text('Politica de Privacidad'), findsOneWidget);

        expect(find.byType(TextButton), findsOneWidget);
      });
}
