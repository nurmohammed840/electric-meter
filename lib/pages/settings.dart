import 'package:desco_usage/app_state.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          appSettings.theme.watch(
            (_) => SwitchListTile(
              title: const Text("Dark Mode"),
              subtitle: const Text("Use dark theme"),
              secondary: const Icon(Icons.dark_mode),
              value: appSettings.theme.value == ThemeMode.dark,
              onChanged: (value) {
                appSettings.theme.set(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
        ],
      ),
    );
  }
}
