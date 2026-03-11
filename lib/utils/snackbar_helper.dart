import 'package:flutter/material.dart';

class AppGlobals {
  static DateTime appStart = DateTime.now();
  static const Duration safeDelay = Duration(seconds: 2);
}

/// Shows a SnackBar but defers it if called too early during app startup.
void showAppSnackBar(BuildContext context, SnackBar snackBar) {
  final diff = DateTime.now().difference(AppGlobals.appStart);
  if (diff < AppGlobals.safeDelay) {
    final remaining = AppGlobals.safeDelay - diff;
    Future.delayed(remaining, () {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
