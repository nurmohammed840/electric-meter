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

