// app.dart
import 'package:flutter/material.dart';
import 'package:flutter_emoji_picker/flutter_emoji_picker.dart';
import 'screens/splash_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EmojiProvider(
      child: MaterialApp(
        title: 'Heartland Strength',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
