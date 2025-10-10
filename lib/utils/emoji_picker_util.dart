import 'package:flutter/material.dart';
import 'package:flutter_emoji_picker/flutter_emoji_picker.dart';

typedef OnEmojiSelected = void Function(String emoji);

class EmojiPickerUtil {
  Widget buildEmojiButton({
    required OnEmojiSelected onEmojiSelected,
    required Widget child,
  }) {
    return EmojiButton(
      emojiPickerViewConfiguration: EmojiPickerViewConfiguration(
        viewType: ViewType.bottomsheet,
        onEmojiSelected: onEmojiSelected,
      ),
      child: child,
    );
  }
}
