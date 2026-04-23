import 'package:desco_usage/signal.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  static final theme = CreateState(ThemeMode.light);
  static final showConsumerInfo = CreateState(true);
  static final showDailyTakaDiff = CreateState(true);
  static final showAmountLabels = CreateState(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              },
            ),
          ),
          showConsumerInfo.watch(
            (_) => SwitchListTile(
              title: const Text("Consumer Info"),
              subtitle: const Text("Enable to display consumer details"),
              secondary: const Icon(Icons.person),
              value: showConsumerInfo.value,
              onChanged: showConsumerInfo.set,
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
              onChanged: showDailyTakaDiff.set,
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
              onChanged: showAmountLabels.set,
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
                applicationLegalese:
                    "nurmohammed840@gmail.com \n\nThis app is not affiliated with DESCO. It is developed independently to help users track their electricity consumption and balance.",
              );
            },
          ),
        ],
      ),
    );
  }
}
