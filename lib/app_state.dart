import 'package:desco_usage/components/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/api/api.dart';
import '/api/customer.dart';
import '/colors.dart';
import '/signal.dart';

late final Future<AppInstance> _appInstance;

Future<T?> _loadData<T>(Future<T> Function() cb) async {
  isLoading.set(isLoading.value + 1);
  try {
    return await cb();
  } catch (err) {
    // print(err);
  } finally {
    isLoading.set(isLoading.value - 1);
  }
  return null;
}

class MeterInfo {
  Balance balance;
  Color color;

  MeterInfo({required this.balance, required this.color});

  MeterNo meterNo() => MeterNo.fromMeterNo(balance.meterNo);
}

final selectedNav = CreateState(0);
final isLoading = CreateState(0);

CreateState<List<MeterInfo>> meterInfos = CreateState([]);

CreateState<Future<List<int>>> dailyConsumtions = CreateState(Future.value([]));

Future<void> loadDailyConsumtions(Duration duration) async {
  // final today = Date.now();
  // final to = Date.from(today.time().subtract(duration));

  // final a = await Future.wait(
  //   meterInfos.value.map((info) async {
  //     final response = await getDailyConsumptions(info.meterNo(), today, to);
  //   }),
  // );
}

void addMeter(MeterNo meterNo, BuildContext context) async {
  final balance = await _loadData(() => getBalance(meterNo));

  if (balance == null) {
    return; // unknown error
  }

  if (!context.mounted) {
    return;
  }

  if (balance.data == null) {
    return showSnackBar(context, const Text("Meter or account does not exist"));
  }

  // don't add meter if meter already added.
  if (meterInfos.value.any(
    (meter) => meter.balance.meterNo == balance.data!.meterNo,
  )) {
    return showSnackBar(context, const Text("Meter already added"));
  }

  meterInfos.update((list) {
    meterInfos.value.add(
      MeterInfo(balance: balance.data!, color: pickNextColor()),
    );
  });

  _saveMeters();
}

void removeMeter(MeterInfo meter) {
  meterInfos.update((list) {
    list.remove(meter);
  });
  _saveMeters();
}

void _saveMeters() {
  AppInstance.get((app) {
    app.sharedPreferences.setStringList(
      "meters",
      meterInfos.value.map((meter) => meter.balance.meterNo).toList(),
    );
  });
}

class AppSettings {
  final theme = CreateState(ThemeMode.light);
}

final appSettings = AppSettings();

class AppInstance {
  SharedPreferences sharedPreferences;
  AppInstance({required this.sharedPreferences});

  static void get(void Function(AppInstance) fn) {
    _appInstance.then(fn, onError: (_) => {});
  }

  static void init() {
    Future<AppInstance> initInstance() async {
      final sharedPreferences = await SharedPreferences.getInstance();

      final meters = sharedPreferences.getStringList("meters") ?? [];

      final getBalances = meters
          .map(MeterNo.from)
          .whereType<MeterNo>()
          .map((meterNo) => _loadData(() => getBalance(meterNo)));

      final balances = await Future.wait(getBalances);

      final data = balances
          .map((res) => res?.data)
          .whereType<Balance>()
          .map((balance) => MeterInfo(balance: balance, color: pickNextColor()))
          .toList();

      meterInfos.set(data);

      return AppInstance(sharedPreferences: sharedPreferences);
    }

    _appInstance = initInstance();
  }
}
