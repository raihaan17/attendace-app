import 'package:flutter/material.dart';

void showErrorAlert(BuildContext context, String message) {
  if (!context.mounted) return;

  final colorScheme = Theme.of(context).colorScheme;
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: colorScheme.error,
        content: Row(
          children: [
            Icon(Icons.error, color: colorScheme.onError),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onError),
              ),
            ),
          ],
        ),
      ),
    );
}

void showSuccessAlert(BuildContext context, String message) {
  if (!context.mounted) return;

  final colorScheme = Theme.of(context).colorScheme;
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: colorScheme.primary,
        content: Row(
          children: [
            Icon(Icons.check, color: colorScheme.onPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
}
