import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ConnectifyApp());
}

class ConnectifyApp extends StatelessWidget {
  const ConnectifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connectify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}
