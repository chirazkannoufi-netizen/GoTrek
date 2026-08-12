import 'package:flutter/material.dart';

/// Honest placeholder for controls that are part of the design but have no
/// implementation behind them yet, so they never read as a dead tap.
void showNotConnected(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('$feature is not connected in this build yet.')),
    );
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
