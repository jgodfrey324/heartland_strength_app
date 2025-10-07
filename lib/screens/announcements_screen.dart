// Entry Point for Announcements
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartlandstrengthapp/services/announcement_service.dart';
import '../widgets/announcements/message_tile.dart';
import '../widgets/announcements/message_input.dart';
import '../widgets/announcements/comments_sheet.dart';

class AnnouncementsScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const AnnouncementsScreen({super.key, required this.userData});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnnouncementService _announcementService = AnnouncementService();

  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _postMessage() async {
    final text = _messageController.text;
    if (text.isEmpty) return;

    try {
      await _announcementService.postMessage(
        text: text,
        userName: widget.userData?['firstName'] ?? 'Anonymous',
      );
      _messageController.clear();
      // TODO: Trigger push notification here if needed
    } catch (e) {
      // Handle error e.g. show a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post message: $e')),
      );
    }
  }

  void _showComments(String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => CommentsSheet(messageId: messageId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Announcements'),
      // ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('announcements')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No announcements yet.'));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data()! as Map<String, dynamic>;

                    return MessageTile(
                      messageDoc: doc,
                      data: data,
                      onCommentsPressed: () => _showComments(doc.id),
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(
            controller: _messageController,
            onSend: _postMessage,
          ),
        ],
      ),
    );
  }
}
