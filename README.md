# SENA Advanced Mobile Programming

Flutter laboratory activities are located in the `sena_mobile` project.

## Lab Activity 2: Discussion

The application follows a layered design pattern that separates API data,
business logic, and presentation. `Product` and its related model classes define
the structure of data returned by the endpoint and convert JSON values into
null-safe Dart objects. `ProductService` is responsible for requesting the
DummyJSON `/products` endpoint, checking the HTTP response, decoding its JSON,
and returning a `Future<List<Product>>` to the interface.

`ProductScreen` calls the service once during initialization and uses a
`FutureBuilder` to render loading, error, empty, and successful states. When data
is available, the screen displays the products in a responsive grid. This flow
keeps networking out of the widgets and makes each layer easier to read, test,
and change independently.

Provider supplies `ThemeProvider` above the entire application. When its state
is changed, `notifyListeners()` rebuilds listening widgets and `MaterialApp`
switches between light and dark themes. This demonstrates how the provider
pattern manages application-wide state separately from local screen state.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
