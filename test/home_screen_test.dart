import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_app/screens/home_screen.dart';

void main() {
  testWidgets('Muestra loader y luego productos en HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsWidgets);
    expect(find.textContaining('Fjallraven - Foldsack No. 1 Backpack'), findsWidgets);
  });
}
