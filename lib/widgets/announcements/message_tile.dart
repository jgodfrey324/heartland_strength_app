import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reaction_bar.dart';
import '../../services/announcement_service.dart';
import '../../utils/emoji_picker_util.dart';

class MessageTile extends StatelessWidget {
  final DocumentSnapshot messageDoc;
  final Map<String, dynamic> data;
  final VoidCallback onCommentsPressed;

  const MessageTile({
    super.key,
    required this.messageDoc,
    required this.data,
    required this.onCommentsPressed,
  });

  void _handleEmojiSelected(BuildContext context, String emoji) async {
    await AnnouncementService().toggleReaction(
      messageId: messageDoc.id,
      emoji: emoji,
    );
    // Optionally show a SnackBar or similar feedback here
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String senderId = data['userId'] ?? '';
    final String userName = data['userName'] ?? 'Unknown';
    final String messageText = data['text'] ?? '';
    final bool isCurrentUser = currentUserId == senderId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Username
          Text(
            userName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),

          // Message and comment button
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // If it's someone else's message, show comment bubble first
              if (!isCurrentUser)
                _buildCommentButton(isCurrentUser, onCommentsPressed),

              // Message bubble
              Flexible(
                child: GestureDetector(
                  onDoubleTap: () {
                    EmojiPickerUtil().showEmojiPicker(
                      context: context,
                      onEmojiSelected: (emoji) =>
                          _handleEmojiSelected(context, emoji),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? Colors.blue.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      messageText,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),

              // If it's current user's message, show comment bubble last
              if (isCurrentUser)
                _buildCommentButton(isCurrentUser, onCommentsPressed),
            ],
          ),

          const SizedBox(height: 6),

          // Reaction bar
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: ReactionBar(messageId: messageDoc.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentButton(bool isCurrentUser, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: const Icon(
          Icons.comment_outlined,
          size: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
