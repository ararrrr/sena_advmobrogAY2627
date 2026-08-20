## Lab Activity 3: Discussion

The Cart Model, service, and screen work together to get and display the cart information. The Cart Model holds the data, while the service gets the information from the API. After receiving the data, the screen uses it to show the correct cart details in detail_screen.dart. The updated design pattern separates the project into models, services, screens, providers, and widgets. Each part has its own purpose, which keeps the code organized and makes it easier to find and change specific parts of the project. For getById, the cart ID is included in the API request so it only gets the information for a specific cart instead of getting all carts. The returned data is stored in the Cart Model and then shown on the detail screen.

