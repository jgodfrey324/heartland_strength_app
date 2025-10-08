// Entry point for profile home screen
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const ProfileScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Content'));
  }
}
