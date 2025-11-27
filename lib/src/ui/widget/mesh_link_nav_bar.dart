import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/ui/theme.dart';

/// A navigation bar for the Mesh Link page.
/// This will be shown when user navigates to an external webpage,
/// such as a 3rd party integration.
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
    final backgroundColor = getNavBarColor(brightness);

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
