import 'package:flutter/material.dart';

import '/components/optional.dart';
import '/signal.dart';

class LoadingIndicator extends StatelessWidget {
  LoadingIndicator({super.key});

  final state = CreateState(0);

  Future<T> show<T>(Future<T> Function() cb) async {
    state.value += 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.notify();
    });
    try {
      return await cb();
    } finally {
      state.set(state.value - 1);
    }
  }

  bool isLoading() {
    return state.value > 0;
  }

  @override
  Widget build(BuildContext context) {
    return state.watch(
      (_) => Optional(
        condition: isLoading(),
        builder: (_) => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
