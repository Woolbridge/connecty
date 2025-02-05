Connectify — Flutter + Laravel Real-Time Chat
Connectify is a location-based social and chat application built with Flutter (for the mobile/web frontend) and Laravel (for the backend). It uses Socket.IO (via Soketi or similar) to provide real-time messaging, typing indicators, and read receipts over WebSockets.

Features
Register & Login: Users can create accounts, log in, and store their tokens in SharedPreferences.
Location Updates: Users can refresh their location, which is sent to the Laravel backend.
Nearby Discovery: The app retrieves users near the authenticated user based on location.
Real-Time Chat:
Send & Receive Messages: Messages appear instantly on both ends via Socket.IO.
Typing Indicators: Shows “Typing...” in the chat header when the other user is typing.
Read Receipts: Displays double checkmarks when a message is read.
Purchases (optional): Users can buy premium or add balance via the integrated Transaction system.
Technologies
Flutter: Frontend mobile/web app
laravel_echo and socket_io_client for real-time functionality
emoji_picker_flutter for emoji support
Laravel: Backend REST API
Sanctum or another auth system for token-based authentication
Events (MessageSent, TypingEvent, MessageRead) broadcast via Socket.IO
Policies or manual checks for message authorization
Soketi / Socket.IO: Self-hosted real-time server bridging Laravel and Flutter using WebSockets
Repository Structure
bash
Copy
Edit
root/
├─ backend/                   # Laravel backend
│  ├─ app/Http/Controllers/
│  │  ├─ AuthController.php   # Handles registration/login
│  │  ├─ DiscoveryController.php   # Updates/gets user location
│  │  ├─ MessageController.php     # Chat endpoints
│  │  ├─ TransactionController.php # Purchases
│  ├─ app/Models/
│  │  ├─ Message.php
│  │  ├─ User.php
│  │  └─ (other models)
│  ├─ routes/
│  │  ├─ api.php              # API endpoints
│  │  └─ channels.php         # Broadcast channels
│  └─ (other Laravel files)
├─ screens/                   # Flutter UI screens
│  ├─ discovery_screen.dart
│  ├─ chat_screen.dart        # Main chat UI & real-time logic
│  ├─ login_screen.dart
│  ├─ register_screen.dart
│  └─ (other screens)
├─ services/
│  └─ api_service.dart        # Flutter API calls
└─ pubspec.yaml               # Flutter dependencies
Prerequisites
Laravel installed (PHP 8.x) with Composer.
Flutter installed (version 3.x or higher recommended).
Soketi/Socket.IO container or server (e.g., Docker: docker run -p 6001:6001 soketi/soketi).
MySQL/PostgreSQL or another DB for the Laravel backend.
Installation & Setup
Clone the repository:

bash
Copy
Edit
git clone https://github.com/yourusername/connectify.git
cd connectify
Laravel Backend:

bash
Copy
Edit
cd backend
composer install
cp .env.example .env
php artisan key:generate
# Update your .env for DB, broadcasting, etc.
php artisan migrate
php artisan serve
In .env, set BROADCAST_DRIVER=pusher and configure your PUSHER_HOST, PUSHER_PORT, etc. for Soketi.
Soketi/Socket.IO:

Run Soketi in Docker:
bash
Copy
Edit
docker run -d --name soketi -p 6001:6001 \
  -e APP_ID=local-app-id \
  -e APP_KEY=local-key \
  -e APP_SECRET=local-secret \
  -e CLUSTER=mt1 \
  soketi/soketi:latest
Flutter Frontend:

bash
Copy
Edit
cd ../ (back to root)
flutter pub get
flutter run
Ensure myUserId (in chat_screen.dart) is replaced dynamically by the actual logged-in user’s ID.
Confirm your IP/port in _setupEcho() matches your Soketi container address.
Usage
Register a user in the app (or via Postman).
Login in the Flutter app to receive a token, which is saved in SharedPreferences.
Location updates let the server know where you are (in DiscoveryScreen).
Nearby Users appear in the discovery screen. Tapping on a user opens a chat.
Chat in real time using WebSockets:
Send messages → Both sides see them instantly.
Typing → The other user sees a “Typing...” indicator.
Read receipts → Double checks show when a message is read.
Common Issues
403 Unauthorized for markAsRead: Make sure you have a MessagePolicy or you remove $this->authorize('update', $message) from markAsRead().
Messages Only Update for Sender: Ensure both users are subscribed to their private channels (private-chat.<userId>) and no ->toOthers() is excluding the sender if needed.
Contributing
Fork this repo & create a new branch.
Make changes & test thoroughly.
Open a Pull Request describing your changes.
License
MIT
