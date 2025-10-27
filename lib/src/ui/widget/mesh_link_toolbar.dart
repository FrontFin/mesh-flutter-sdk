import 'package:flutter/material.dart';

const _backgroundColorDark = Color(0xFF1E1E24);
const _backgroundColorLight = Color(0xFFFBFBFB);
const _iconColor = Colors.white;

class MeshLinkToolbar extends StatelessWidget {
  const MeshLinkToolbar({
    required this.brightness,
    required this.onBackPressed,
    required this.onClosePressed,
    super.key,
  });

  final Brightness brightness;
  final VoidCallback onBackPressed;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (brightness) {
      Brightness.light => _backgroundColorLight,
      Brightness.dark => _backgroundColorDark,
    };

    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.chevron_left, size: 32, color: _iconColor),
            ),
            const Spacer(),
            IconButton(
              onPressed: onClosePressed,
              icon: const Icon(Icons.close, color: _iconColor),
            ),
          ],
        ),
      ),
    );
  }
}
