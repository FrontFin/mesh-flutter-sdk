import 'package:flutter/material.dart';
import 'package:mesh_sdk/src/extension/context.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({required this.onConfirm, super.key});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.exitDialogTitle),
      content: Text(context.l10n.exitDialogMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(context.l10n.exit),
        ),
      ],
    );
  }
}
