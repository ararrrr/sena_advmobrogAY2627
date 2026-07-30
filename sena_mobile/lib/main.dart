import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Runs the application and provides [ThemeModel] to all widgets.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

/// Root widget that applies the light or dark theme to the whole app.
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});

  /// Builds the app using the theme stored in Provider.
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeModel.isDark ? ThemeData.dark() : ThemeData.light(),
      home: const MyHomePage(),
    );
  }
}

/// Stores the app-wide light or dark theme state.
class ThemeModel with ChangeNotifier {
  bool _isDark = false;

  /// Returns the current theme setting.
  bool get isDark => _isDark;

  /// Changes the theme and notifies listening widgets.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

/// Page that displays the ephemeral counter example.
class MyHomePage extends StatefulWidget {
  /// Creates the counter page.
  const MyHomePage({super.key});

  /// Creates the local State object that stores the counter.
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Manages the local counter value using setState.
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  /// Increases the counter and rebuilds only this page.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  /// Builds the counter interface and navigation button.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ephemeral State Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_brightness),
            tooltip: 'Open App State Example',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThemePage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Page that displays the app-wide theme state example.
class ThemePage extends StatelessWidget {
  /// Creates the theme example page.
  const ThemePage({super.key});

  /// Builds the page and reads the shared ThemeModel from Provider.
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App State Example'),
        actions: [
          Switch(
            value: themeModel.isDark,
            onChanged: (value) => themeModel.toggleTheme(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Toggle the theme using the switch in the app bar'),
      ),
    );
  }
}

// setState is best for short-lived state used by one widget, such as the
// counter. Provider is useful for app state shared by many widgets or pages,
// such as the light/dark theme. setState rebuilds its local widget, while
// notifyListeners tells every Provider listener to rebuild when app state
// changes.
