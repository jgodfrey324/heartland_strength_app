import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

typedef OnEmojiSelected = void Function(String emoji);

class EmojiPickerUtil {
  void showEmojiPicker({
    required BuildContext context,
    required OnEmojiSelected onEmojiSelected,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (_) => SizedBox(
        height: 320,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            onEmojiSelected(emoji.emoji);
            Navigator.of(context).pop();
          },
          config: Config(
            columns: 7,
            emojiSizeMax: 32.0,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            initCategory: Category.RECENT,
            bgColor: Colors.white,
            indicatorColor: Colors.blue,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blue,
            backspaceColor: Colors.blue,
            skinToneDialogBgColor: Colors.white,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            // showRecentsTab: true,
            recentsLimit: 28,
            // noRecentsText: 'No Recents',
            // noRecentsStyle: const TextStyle(fontSize: 20, color: Colors.black26),
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: const CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL,
          ),
        ),
      ),
    );
  }
}
