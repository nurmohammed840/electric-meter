import 'package:flutter/material.dart';

import '/components/optional.dart';
import '/signal.dart';



class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  static final isLoading = CreateState(0);

  static Future<T> show<T>(Future<T> Function() cb) async {
    isLoading.set(isLoading.value + 1);
    try {
      return await cb();
    } finally {
      isLoading.set(isLoading.value - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading.watch(
      (_) => Optional(
        condition: isLoading.value > 0,
        builder: (_) => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
