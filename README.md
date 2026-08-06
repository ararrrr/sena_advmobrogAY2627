## Lab Activity 2: Discussion

The application uses a model to store the product information received from the API, while the service retrieves the data and converts the JSON response into Product objects so it can be used in the application. After the data is processed, FutureBuilder waits for the result before displaying the products on the screen, making sure that the information is loaded correctly before it appears to the user. With the project divided into models, services, screens, providers, and widgets, each part has a specific responsibility, making the code easier to read, organize, and maintain instead of placing everything in a single file.

