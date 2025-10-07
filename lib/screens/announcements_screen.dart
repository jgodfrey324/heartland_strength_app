// Entry Point for Announcements
import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const AnnouncementsScreen({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstName = userData?['firstName'] ?? 'User';
    return Center(child: Text('Welcome, $firstName! Here are your announcements.'));
  }
}
