// Entry point for profile home screen
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const ProfileScreen({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Content'));
  }
}
