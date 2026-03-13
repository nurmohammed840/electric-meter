import 'dart:io';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/usage.dart';
import 'screens/recharge_history.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true; // bypass SSL check
  }
}

void main() {
  AppInstance.store.init();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return appSettings.theme.watch(
      (_) => MaterialApp(
        themeMode: appSettings.theme.value,
        theme: .light(),
        darkTheme: .dark(),
        title: 'Desco Usage',
        debugShowCheckedModeBanner: false,
        home: const HomeWidget(),
      ),
    );
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  static const screens = [UsageScreen(), RechargeHistoryScreen()];
  static const destinations = [
    NavigationDestination(icon: Icon(Icons.speed), label: 'Usage'),
    NavigationDestination(
      icon: Icon(Icons.receipt_long),
      label: 'Recharge History',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return selectedNav.watch((_) {
      if (selectedNav.value == 1) {
        RechargeHistoryScreen.onFocus();
      }
      return Scaffold(
        body: IndexedStack(index: selectedNav.value, children: screens),
        bottomNavigationBar: NavigationBar(
          labelBehavior: .alwaysHide,
          selectedIndex: selectedNav.value,
          onDestinationSelected: (idx) => selectedNav.set(idx),
          destinations: destinations,
        ),
      );
    });
  }
}
