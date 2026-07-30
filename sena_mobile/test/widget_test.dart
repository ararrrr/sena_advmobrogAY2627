import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sena_mobile/main.dart';

// Creates the app with the Provider required by MyApp.
Widget createTestApp() {
  return ChangeNotifierProvider(
    create: (context) => ThemeModel(),
    child: const MyApp(),
  );
}

// Tests the ephemeral counter and app-wide theme state.
void main() {
  testWidgets('counter increments', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('switch changes the theme', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());

    MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.brightness, Brightness.light);

    await tester.tap(find.byIcon(Icons.settings_brightness));
    await tester.pumpAndSettle();
    expect(find.text('App State Example'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.brightness, Brightness.dark);
  });
}
