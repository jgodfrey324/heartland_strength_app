// Main entry point for app
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/auth_services.dart';
import '../home_screen.dart';
import 'mobile_app_screen.dart';
import 'web_app_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final data = await _authService.fetchUserData();
    if (data == null) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
      return;
    }
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userId = _authService.getCurrentUserId();
    if (userId == null || _userData == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return kIsWeb
      ? WebAppScreen(
          userId: userId,
          userData: _userData!,
          onSignOut: _signOut,
        )
      : MobileAppScreen(
          userId: userId,
          userData: _userData!,
          onSignOut: _signOut,
        );
  }
}
