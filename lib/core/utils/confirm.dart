import 'package:flutter/material.dart';

Future<bool> showConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Evet',
  String cancelText = 'Vazgeç',
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return res ?? false;
}
