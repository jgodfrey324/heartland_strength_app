// App-level logic and routing
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/splash_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heartland Strength',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
