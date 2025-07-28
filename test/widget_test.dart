import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:RxCheck/main.dart';

// Mock para FlutterSecureStorage
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSecureStorage mockStorage;

  setUpAll(() {
    mockStorage = MockSecureStorage();

    // Reemplaza el método estático por el mock
    FlutterSecureStorage.setMockInitialValues({}); // Esto simula valores vacíos

    // Simulamos que no hay sesión activa
    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);

    // Simula lectura completa del storage
    when(() => mockStorage.readAll()).thenAnswer((_) async => {});
  });

  testWidgets('Carga MyApp y muestra CircularProgressIndicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MyApp(),
      ),
    );

    // Espera el build inicial y posibles FutureBuilder
    await tester.pump();

    // Verifica que hay un CircularProgressIndicator mientras se carga
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
