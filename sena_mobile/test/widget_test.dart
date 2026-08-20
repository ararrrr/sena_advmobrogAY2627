import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sena_mobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('starts on the splash screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SenaMobileApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'SENA Mobile');
    expect(app.initialRoute, '/splash');
  });
}
