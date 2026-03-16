import 'package:desco_usage/cache.dart';
import 'package:desco_usage/format.dart';
import 'package:desco_usage/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/components/error_snackbar.dart';
import '/widgets/loading_indicator.dart';
import '/api/date.dart';
import '/api/api.dart';
import '/api/customer.dart';
import '/colors.dart';
import '/signal.dart';

class MeterRechargeReceipt {
  MeterRechargeReceipt({required this.info, required this.history})
    : formattedDate = dateFormatter.format(history.rechargeDate),
      formattedBalance = balanceFormatter.format(history.totalAmount);

  final MeterInfo info;
  final RechargeReceipt history;
  final String formattedDate;
  final String formattedBalance;
}

class MeterInfo {
  MeterInfo({required this.balance, required this.color})
    : formattedDate = dateFormatterAlt.format(balance.readingTime.time()),
      cacheKey = CacheKey(meterNo: balance.meterNo);

  final Color color;
  final Balance balance;
  final String formattedDate;
  final CacheKey cacheKey;

  late final info = LazyFut(
    init: () => CacheManager.getOrInit(
      cacheKey.customarInfoCKey(),
      Info.fromJson,
      () async {
        final res = await LoadingIndicator.show(
          () => getCustomerInfo(meterNo()),
        );
        return res.getData();
      },
    ),
  );

  late final dailyConsumptions = LazyFut(
    init: () async {
      final today = Date.now();
      final from = Date.from(today.time().subtract(const Duration(days: 120)));

      final res = await getDailyConsumptions(meterNo(), from, today);
      final dailyConsumptions = res.getData();

      return dailyConsumptions;
    },
  );

  MeterNo meterNo() => MeterNo.fromMeterNo(balance.meterNo);
}

final selectedNav = CreateState(0);

CreateState<List<MeterInfo>> meterInfos = CreateState([]);

CreateState<Future<List<MeterRechargeReceipt>>> rechargeHistorys = CreateState(
  Future.value([]),
);

void loadRechargeHistorys(Duration duration) async {
  Future<List<MeterRechargeReceipt>> load() async {
    try {
      return await fetchRechargeHistorys(duration);
    } catch (e) {
      return [];
    }
  }

  rechargeHistorys.set(load());
}

Future<List<MeterRechargeReceipt>> fetchRechargeHistorys(
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
              (history) => MeterRechargeReceipt(history: history, info: info),
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
      .whereType<List<MeterRechargeReceipt>>()
      .expand((e) => e)
      .toList();
}

void addMeter(MeterNo meterNo, BuildContext context) async {
  final balance = await LoadingIndicator.show(() => getBalance(meterNo));

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
  AppInstance.store.sharedPreferences.setStringList(
    "meters",
    meterInfos.value.map((meter) => meter.balance.meterNo).toList(),
  );
}

class AppSettings {}

final appSettings = AppSettings();

class AppInstance {
  AppInstance();

  static final AppInstance store = AppInstance();

  final SharedPreferencesAsync sharedPreferences = SharedPreferencesAsync();

  void init() async {
    final meters = await sharedPreferences.getStringList("meters") ?? [];

    final getBalances = meters
        .map(MeterNo.from)
        .whereType<MeterNo>()
        .map((meterNo) => LoadingIndicator.show(() => getBalance(meterNo)));

    final balances = await Future.wait(getBalances);

    final data = balances
        .map((res) => res.data)
        .whereType<Balance>()
        .map((b) => MeterInfo(balance: b, color: colorPicker.next()))
        .toList();

    meterInfos.set(data);
  }
}
