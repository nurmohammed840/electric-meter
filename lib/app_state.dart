import 'package:desco_usage/api/date.dart';
import 'package:desco_usage/components/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

final dateFormatter = DateFormat('d MMM yyyy, h:mm a');
final dateFormatterAlt = DateFormat('MMMM d');
final balanceFormatter = NumberFormat('#,##0.##');

class MeterRechargeHistory {
  MeterRechargeHistory({required this.info, required this.history})
    : formattedDate = dateFormatter.format(history.rechargeDate),
      formattedBalance = balanceFormatter.format(history.totalAmount);

  final MeterInfo info;
  final RechargeHistory history;
  final String formattedDate;
  final String formattedBalance;
}

class MeterInfo {
  MeterInfo({required this.balance, required this.color})
    : formattedDate = dateFormatterAlt.format(balance.readingTime.time());

  final Balance balance;
  final Color color;
  final String formattedDate;

  MeterNo meterNo() => MeterNo.fromMeterNo(balance.meterNo);
}

final selectedNav = CreateState(0);
final isLoading = CreateState(0);

CreateState<List<MeterInfo>> meterInfos = CreateState([]);

CreateState<Future<List<MeterRechargeHistory>>> rechargeHistorys = CreateState(
  Future.value([]),
);

void loadRechargeHistorys(Duration duration) async {
  Future<List<MeterRechargeHistory>> load() async {
    try {
      return await fetchRechargeHistorys(duration);
    } catch (e) {
      return [];
    }
  }

  rechargeHistorys.set(load());
}

Future<List<MeterRechargeHistory>> fetchRechargeHistorys(
  Duration duration,
) async {
  final today = Date.now();
  final from = Date.from(today.time().subtract(duration));

  final responses = await Future.wait(
    meterInfos.value.map((info) async {
      try {
        final list = await getRechargeHistorys(info.meterNo(), from, today);
        if (list.data == null) return null;

        final result = list.data!
            .map(
              (history) => MeterRechargeHistory(history: history, info: info),
            )
            .toList();

        return result;
      } catch (e) {
        // print(e);
        return null;
      }
    }),
  );

  return responses
      .whereType<List<MeterRechargeHistory>>()
      .expand((e) => e)
      .toList();
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
      MeterInfo(balance: balance.data!, color: colorPicker.next()),
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
          .map((b) => MeterInfo(balance: b, color: colorPicker.next()))
          .toList();

      meterInfos.set(data);

      return AppInstance(sharedPreferences: sharedPreferences);
    }

    _appInstance = initInstance();
  }
}
