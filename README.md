# 1 Laboratory Discussion

SetState is useful for managing small and temporary changes within a single widget or screen. For example, it can update a counter whenever the user presses a button. It is simple and easy to use, but it can become difficult to manage when many widgets need the same data. Provider is better for managing data shared across different widgets or pages. For example, changing the app’s theme through Provider updates every page that uses that theme. It also helps keep the state-management code more organized as the application becomes larger.

# 2 Laboratory Discussion

The application uses a model to store the product information received from the API, while the service retrieves the data and converts the JSON response into Product objects so it can be used in the application. After the data is processed, FutureBuilder waits for the result before displaying the products on the screen, making sure that the information is loaded correctly before it appears to the user. With the project divided into models, services, screens, providers, and widgets, each part has a specific responsibility, making the code easier to read, organize, and maintain instead of placing everything in a single file.
