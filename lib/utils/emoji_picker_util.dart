import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

typedef OnEmojiSelected = void Function(String emoji);

class EmojiPickerUtil {
  void showEmojiPicker({
    required BuildContext context,
    required OnEmojiSelected onEmojiSelected,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (_) => Material(
        child: SizedBox(
          height: 320,
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              onEmojiSelected(emoji.emoji);
              Navigator.of(context).pop();
            },
            config: Config(
              height: 256,
              checkPlatformCompatibility: true,
              viewOrderConfig: const ViewOrderConfig(),
              emojiViewConfig: EmojiViewConfig(
                emojiSizeMax: 28 *
                    (foundation.defaultTargetPlatform ==
                            TargetPlatform.iOS
                        ? 1.2
                        : 1.0),
              ),
              skinToneConfig: const SkinToneConfig(),
              categoryViewConfig: const CategoryViewConfig(),
              bottomActionBarConfig: const BottomActionBarConfig(),
              searchViewConfig: const SearchViewConfig(),
            ),
          ),
        ),
      ),
    );
  }
}
