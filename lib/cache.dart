import 'dart:convert';

import 'package:desco_usage/app_state.dart';
import 'package:desco_usage/types.dart';

class CacheKey {
  const CacheKey({required this.meterNo});

  final String meterNo;

  String customarInfoCKey() => "_CI_$meterNo";
}

class CacheManager {
  static Future<void> set(String key, JsonSerializable obj) async {
    await AppInstance.store.sharedPreferences.setString(
      key,
      obj.toJsonString(),
    );
  }

  static Future<T?> get<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final json = await AppInstance.store.sharedPreferences.getString(key);
    if (json == null) return null;
    return fromJson(jsonDecode(json));
  }

  static Future<T> getOrInit<T extends JsonSerializable>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
    Future<T> Function() init,
  ) async {
    final cached = await get(key, fromJson);
    if (cached != null) return cached;

    final value = await init();
    await set(key, value);
    return value;
  }
}
