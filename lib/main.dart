import 'package:flutter/material.dart';

void main() {
  runApp(const SafeFyApp());
}

class SafeFyApp extends StatelessWidget {
  const SafeFyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeFy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08142B),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'SafeFy',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}