// Custom comment button
import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CommentButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
