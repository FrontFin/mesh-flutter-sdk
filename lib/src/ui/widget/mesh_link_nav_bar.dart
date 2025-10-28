import 'package:flutter/material.dart';
import 'package:mesh_sdk/src/ui/theme.dart';

class MeshLinkNavBar extends StatelessWidget {
  const MeshLinkNavBar({
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
    const iconColor = iconColorDark;
    final backgroundColor = switch (brightness) {
      Brightness.light => navBarColorLight,
      Brightness.dark => navBarColorDark,
    };

    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.chevron_left, size: 32, color: iconColor),
            ),
            const Spacer(),
            IconButton(
              onPressed: onClosePressed,
              icon: const Icon(Icons.close, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}
