# Connectify — Flutter + Laravel Real-Time Chat

**Connectify** is a location-based social and chat application built with **Flutter** (for the mobile/web frontend) and **Laravel** (for the backend). It uses **Socket.IO** (via [Soketi](https://github.com/soketi/soketi) or another Socket.IO server) to deliver **real-time** messaging, typing indicators, and read receipts over **WebSockets**.

---

## Table of Contents
1. [Features](#features)
2. [Technologies](#technologies)
3. [Prerequisites](#prerequisites)
4. [Project Structure](#project-structure)
5. [Installation & Setup](#installation--setup)
6. [Usage](#usage)
7. [Common Issues](#common-issues)
8. [Contributing](#contributing)
9. [License](#license)

---

## Features

- **Register & Login**  
  Users can register for an account, log in securely, and store their auth tokens in `SharedPreferences`.

- **Location-Based Discovery**  
  - **Refresh Location**: Share your position with the backend via the `DiscoveryController`.
  - **Nearby Users**: Retrieves users within a specified radius.

- **Real-Time Chat**  
  - **Instant Messaging**: Send/receive messages in real time using Socket.IO.
  - **Typing Indicators**: Display “Typing...” in the chat header when the other user is typing.
  - **Read Receipts**: Show double checkmarks when a message has been read by the recipient.

- **Purchases (Optional)**  
  - **Buy Premium**: Upgrade user account.
  - **Add Balance**: Increase your wallet balance through the `TransactionController`.

---

## Technologies

- **Flutter**  
  - `laravel_echo` and `socket_io_client` for real-time communication  
  - `emoji_picker_flutter` for an emoji picker in chat  
- **Laravel**  
  - Sanctum (or another auth) for token-based authentication  
  - Broadcasting events (`MessageSent`, `TypingEvent`, `MessageRead`) via Socket.IO channels
- **Soketi / Socket.IO**  
  - Self-hosted WebSocket server bridging Laravel and Flutter

---

## Prerequisites

1. **Laravel** (PHP 8.x) with Composer
2. **Flutter** (3.x or newer recommended)
3. **Soketi or Socket.IO** container/server
4. **MySQL / Postgres** or another DB for Laravel
5. Node.js (optional, if you’re running a custom Socket.IO setup)

---

## Project Structure

```bash
.
├─ backend/                    # Laravel Backend
│  ├─ app/
│  │  ├─ Http/Controllers/
│  │  │  ├─ AuthController.php
│  │  │  ├─ DiscoveryController.php
│  │  │  ├─ MessageController.php
│  │  │  ├─ TransactionController.php
│  │  ├─ Models/
│  │  │  ├─ Message.php
│  │  │  ├─ User.php
│  │  │  └─ ...
│  ├─ routes/
│  │  ├─ api.php               # API endpoints
│  │  └─ channels.php          # Broadcast channels
│  └─ ...
├─ screens/                    # Flutter UI Screens
│  ├─ discovery_screen.dart
│  ├─ chat_screen.dart         # Main chat UI & real-time logic
│  ├─ login_screen.dart
│  ├─ register_screen.dart
│  └─ ...
├─ services/
│  └─ api_service.dart         # Flutter API calls
├─ pubspec.yaml                # Flutter dependencies
└─ ...
