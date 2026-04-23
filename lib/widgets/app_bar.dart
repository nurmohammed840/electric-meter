import 'package:desco_usage/pages/settings.dart';
import 'package:desco_usage/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

import '/app_state.dart';
import '/dialogs/add_meter.dart';

AppBar appBar(String title, {Widget? actionButton, void Function()? refrash}) =>
    AppBar(
      title: Text(title),
      actions: [
        const LoadingIndicator(),
        ?actionButton,
        PopupMenuButton(
          position: .under,
          icon: const Padding(
            padding: .symmetric(horizontal: 8),
            child: Icon(Icons.more_vert),
          ),
          onSelected: (value) {},
          itemBuilder: (context) => [
            if (refrash != null)
              PopupMenuItem(
                value: 'refresh',
                onTap: refrash,
                child: const Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),

            PopupMenuItem(
              value: 'add_meter',
              onTap: () async {
                final meterNo = await acceptMeterNo(context);
                if (meterNo == null) {
                  return;
                }
                if (!context.mounted) return;
                addMeter(meterNo, context);
              },
              child: const Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Add Meter'),
                ],
              ),
            ),

            PopupMenuItem(
              value: 'settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Settings()),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
