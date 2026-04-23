import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, Widget content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: content, behavior: .floating, showCloseIcon: true),
  );
}

Future<T?> showSnackBarOnError<T>(
  BuildContext context,
  Future<T> Function() cb,
) async {
  try {
    return await cb();
  } catch (error) {
    if (context.mounted) showErrorSnackBar(context, error);
  }
  return null;
}

void showErrorSnackBar(BuildContext context, Object error) {
  showSnackBar(context, Text(errorMsg(error)));
}

String errorMsg(Object error) {
  return switch (error) {
    SocketException() => "No internet connection",
    TimeoutException() => "Connection timeout",
    _ => error.toString(),
  };
}
