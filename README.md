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
is available, the screen filters it using the search query and displays the
matching products in a responsive grid. Selecting a card passes its `Product`
object to `ProductDetailsScreen`, where additional model fields are rendered.
This flow keeps networking out of the widgets and makes each layer easier to
read, test, and change independently.

Provider supplies `ThemeProvider` above the entire application. The settings
screen updates that shared state using `toggleTheme()`, `notifyListeners()`
rebuilds listening widgets, and `MaterialApp` switches between light and dark
themes. This demonstrates how the provider pattern manages application-wide
state separately from the local search and navigation state owned by individual
screens.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
