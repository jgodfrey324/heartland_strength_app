import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'reaction_bar.dart';
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
    final String userName = data['userName'] ?? 'Unknown';
    final String messageText = data['text'] ?? '';

    return GestureDetector(
      onDoubleTap: () {
        EmojiPickerUtil().showEmojiPicker(
          context: context,
          onEmojiSelected: (emoji) => _handleEmojiSelected(context, emoji),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // Stack: Message box + floating comment bubble
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Message box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    messageText,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),

                // Comment bubble (90% outside, 10% inside)
                Positioned(
                  bottom: -12,
                  right: -12,
                  child: GestureDetector(
                    onTap: onCommentsPressed,
                    child: Container(
                      width: 30,
                      height: 30,
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
