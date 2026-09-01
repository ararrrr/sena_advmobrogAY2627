# Laboratory Activities

## Lab Act 1

Lab Act 1 introduced the basic structure of a Flutter mobile application and the use of reusable widgets. The activity focused on arranging interface elements with widgets such as `Scaffold`, `AppBar`, `Column`, `Row`, and `ListView`. Assets, colors, text styles, and spacing were combined to create a clear and consistent layout. Separating sections of the interface into widgets made the source code easier to understand and maintain. This activity established the Flutter fundamentals needed for the succeeding laboratory exercises.

## Lab Act 2

Lab Act 2 introduced models and services for retrieving structured information from an API. The model defines the fields used by the application and converts JSON responses into Dart objects. The service is responsible for sending the request, checking the response, and returning the converted model data. A `FutureBuilder` waits for the asynchronous operation before displaying loading, error, or completed states on the screen. This separation gives models, services, and screens clear responsibilities and makes the project easier to maintain.

## Lab Act 3

Lab Act 3 expanded the application by organizing additional features into dedicated screens, providers, and reusable widgets. Providers manage shared state and notify listening screens whenever application data changes. Screens focus on presenting the current state, while reusable widgets keep repeated interface elements consistent. Navigation connects the different pages without combining unrelated responsibilities in one file. This activity demonstrated how organized state management and reusable components support a larger Flutter application.

## Lab Act 4

Lab Act 4 connected the application layers so that models, services, providers, and screens work together. Services request external data and convert each JSON response into model objects before returning the result. Providers hold shared state, save user preferences when required, and notify the interface when the state changes. Screens consume those objects and rebuild their widgets after asynchronous operations complete. This layered approach separates data structure, network communication, state management, and presentation, making the application easier to test and extend.
