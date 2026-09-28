# 1 Laboratory Discussion

SetState is useful for managing small and temporary changes within a single widget or screen. For example, it can update a counter whenever the user presses a button. It is simple and easy to use, but it can become difficult to manage when many widgets need the same data. Provider is better for managing data shared across different widgets or pages. For example, changing the app's theme through Provider updates every page that uses that theme. It also helps keep the state-management code more organized as the application becomes larger.

---

# 2 Laboratory Discussion

The application uses a model to store the product information received from the API, while the service retrieves the data and converts the JSON response into Product objects so it can be used in the application. After the data is processed, FutureBuilder waits for the result before displaying the products on the screen, making sure that the information is loaded correctly before it appears to the user. With the project divided into models, services, screens, providers, and widgets, each part has a specific responsibility, making the code easier to read, organize, and maintain instead of placing everything in a single file.

---

# 3 Laboratory Discussion

The Cart Model, service, and screen work together to get and display the cart information. The Cart Model holds the data, while the service gets the information from the API. After receiving the data, the screen uses it to show the correct cart details in detail_screen.dart. The updated design pattern separates the project into models, services, screens, providers, and widgets. Each part has its own purpose, which keeps the code organized and makes it easier to find and change specific parts of the project. For getById, the cart ID is included in the API request so it only gets the information for a specific cart instead of getting all carts. The returned data is stored in the Cart Model and then shown on the detail screen.

---

# 4 Laboratory Discussion

The User Model, service, and screen work together to get and display the user information. The User Model holds the user data, while the service gets the information from the API. After the data is received, the profile_screen uses it to display the correct user details. The updated design pattern separates the project into models, services, screens, providers, and widgets. This keeps the code organized because each part has its own task, making the project easier to manage and update. The saved user data can also be used to render the cart screen by user ID. The saved ID is used to find the carts that belong to that specific user, then the API returns the cart data and displays it on the cart screen.

---

# 5 Laboratory Discussion

In this activity, the workflow for authentication is divided between DummyJSON and Firebase. For DummyJSON, authentication relies on mock REST API calls to retrieve simulated user profiles and tokens, which are stored locally in SharedPreferences. In contrast, Firebase uses the FirebaseAuth SDK where sign-up and sign-in directly communicate with Google's cloud authentication service, handling real-time credential validation, secure password hashing, and token issuance. The main idea behind the UserService implementation is to centralize and decouple all authentication and user data management logic from the UI. By keeping API requests, Firebase SDK calls, and session persistence inside UserService, the screens (SignIn, SignUp, Profile, and Settings) remain clean and only interact with the service methods. The Firebase implementation benefits the application by providing real cloud authentication, reactive state tracking with authStateChanges(), secure account management features (such as updating usernames, resetting passwords with re-authentication, and deleting accounts), and eliminating the security risks of managing passwords locally.

---

# 6 Laboratory Discussion

In this activity, Cloud Firestore organizes chat data using two main collections: the Users collection and the chat_rooms collection. The Users collection stores individual user documents identified by their unique Firebase Auth UID, containing profile information such as their name, email, and username, which the application streams in real time to display all registered users in the chat list. When two users initiate a chat, the application combines and sorts both user UIDs alphabetically to generate a unique chatRoomID, creating a document inside the chat_rooms collection with a nested messages subcollection. Each message document within this subcollection stores the message content, sender ID, receiver ID, timestamp, and delivery status using the MessageModel. If a user initiates a chat with themselves, the sorted sender and receiver IDs result in a room ID combining their own UID twice. Firestore still creates the room and stores the messages without errors, but because the sender ID matches the logged-in user ID for every message, all messages evaluate as outgoing and render on the right side of the screen, effectively functioning like a personal note-taking chat.

