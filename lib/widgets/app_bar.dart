import 'package:desco_usage/pages/settings.dart';
import 'package:flutter/material.dart';

import '/app_state.dart';
import '/components/optional.dart';
import '/dialogs/add_meter.dart';

AppBar appBar(String title) => AppBar(
  title: Text(title),
  actions: [
    isLoading.watch(
      (_) => Optional(
        condition: isLoading.value > 0,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(),
        ),
      ),
    ),

    PopupMenuButton(
      position: .under,
      icon: const Padding(
        padding: .symmetric(horizontal: 8),
        child: Icon(Icons.more_vert),
      ),
      onSelected: (value) {},
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'add_meter',
          child: const Row(
            children: [Icon(Icons.add), SizedBox(width: 8), Text('Add Meter')],
          ),
          onTap: () async {
            final meterNo = await acceptMeterNo(context);
            if (meterNo == null) {
              return;
            }
            addMeter(meterNo);
          },
        ),
        PopupMenuItem(
          value: 'settings',
          child: const Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
        ),
      ],
    ),
  ],
);
