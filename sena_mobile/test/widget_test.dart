import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sena_mobile/main.dart';

void main() {
  testWidgets('starts on the SENA home screen', (tester) async {
    await tester.pumpWidget(const SenaMobileApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'SENA Mobile');
    expect(app.initialRoute, '/home');
  });
}
