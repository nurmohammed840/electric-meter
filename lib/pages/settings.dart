import 'package:desco_usage/app_state.dart';
import 'package:desco_usage/signal.dart';
import 'package:flutter/material.dart';

const applicationLegalese = """nurmohammed840@gmail.com

This app is not affiliated with DESCO. It is developed independently to help users track their electricity consumption and balance.""";

final _store = AppInstance.store.sharedPreferences;

class Settings extends StatelessWidget {
  const Settings({super.key});

  static final theme = CreateState(ThemeMode.light);
  static final showConsumerInfo = CreateState(true);
  static final showDailyTakaDiff = CreateState(true);
  static final showAmountLabels = CreateState(true);
  static final lowBalanceThreshold = CreateState(const RangeValues(100, 250));

  static void load() async {
    theme.set(
      (await _store.getBool("Settings.isDark")) == true ? .dark : .light,
    );
    showConsumerInfo.set(
      (await _store.getBool("Settings.showConsumerInfo")) ?? true,
    );
    showDailyTakaDiff.set(
      (await _store.getBool("Settings.showDailyTakaDiff")) ?? true,
    );
    showAmountLabels.set(
      (await _store.getBool("Settings.showAmountLabels")) ?? true,
    );

    final lowStart = await _store.getDouble("Settings.lowBalance.start");
    final lowEnd = await _store.getDouble("Settings.lowBalance.end");

    if (lowStart != null && lowEnd != null) {
      lowBalanceThreshold.set(RangeValues(lowStart, lowEnd));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Settings")),
    body: ListView(
      children: [
        theme.watch(
          (_) => SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Use dark theme"),
            secondary: const Icon(Icons.dark_mode),
            value: theme.value == .dark,
            onChanged: (value) {
              theme.set(value ? .dark : .light);
              _store.setBool("Settings.isDark", value);
            },
          ),
        ),
        showConsumerInfo.watch(
          (_) => SwitchListTile(
            title: const Text("Consumer Info"),
            subtitle: const Text("Enable to display consumer details"),
            secondary: const Icon(Icons.person),
            value: showConsumerInfo.value,
            onChanged: (value) {
              showConsumerInfo.set(value);
              _store.setBool("Settings.showConsumerInfo", value);
            },
          ),
        ),
        showDailyTakaDiff.watch(
          (_) => SwitchListTile(
            title: const Text("Consumption Amount Delta"),
            subtitle: const Text(
              "Show line chart for daily consumed difference in Taka",
            ),
            secondary: const Icon(Icons.trending_up),
            value: showDailyTakaDiff.value,
            onChanged: (value) {
              showDailyTakaDiff.set(value);
              _store.setBool("Settings.showDailyTakaDiff", value);
            },
          ),
        ),
        showAmountLabels.watch(
          (_) => SwitchListTile(
            title: const Text("Show Amount Labels"),
            subtitle: const Text(
              "Display Taka values on the consumption line chart at top",
            ),
            secondary: const Text(
              "৳",
              style: TextStyle(fontSize: 26, fontWeight: .bold),
            ),
            value: showAmountLabels.value,
            onChanged: (value) {
              showAmountLabels.set(value);
              _store.setBool("Settings.showAmountLabels", value);
            },
          ),
        ),

        ListTile(
          leading: const Icon(Icons.payments),
          title: const Text("Low Balance Alert"),
          isThreeLine: true,
          titleAlignment: .center,
          subtitle: lowBalanceThreshold.watch(
            (_) => Column(
              crossAxisAlignment: .start,
              children: [
                Padding(
                  padding: const .only(top: 4, bottom: 8),
                  child: Text(
                    'Low balance range (${lowBalanceThreshold.value.start.round()} - ${lowBalanceThreshold.value.end.round()})',
                  ),
                ),
                RangeSlider(
                  values: lowBalanceThreshold.value,
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  onChanged: lowBalanceThreshold.set,
                  onChangeEnd: (value) {
                    _store.setDouble("Settings.lowBalance.start", value.start);
                    _store.setDouble("Settings.lowBalance.end", value.end);
                  },
                ),
              ],
            ),
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.question_mark),
          title: const Text("About"),
          subtitle: const Text("App info, licenses & support"),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationVersion: "1.0.0",
              applicationLegalese: applicationLegalese,
            );
          },
        ),
      ],
    ),
  );
}
