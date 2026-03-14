import 'package:desco_usage/components/error_snackbar.dart';
import 'package:flutter/material.dart';

class OnceInit {
  bool _called = false;

  T? call<T>(T Function() fn) {
    if (_called) return null;
    _called = true;
    return fn();
  }

  Future<T?> callAsync<T>(Future<T> Function() fn) async {
    if (_called) return null;
    _called = true;
    return await fn();
  }
}

class LazyFut<T> {
  LazyFut({required this.init});

  final Future<T> Function() init;
  T? value;

  Future<T> get() async {
    if (value == null) {
      value = await init();
    }
    return value!;
  }

  Future<T?> getOrShowSnackBarErr(BuildContext context) async {
    return showSnackBarOnError(context, get);
  }
}
