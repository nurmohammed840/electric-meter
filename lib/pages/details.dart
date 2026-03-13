import 'package:desco_usage/app_state.dart';
import 'package:desco_usage/colors.dart';
import 'package:desco_usage/widgets/table_data.dart';
import 'package:flutter/material.dart';

class MeterDetailsPage extends StatelessWidget {
  const MeterDetailsPage({super.key, required this.meter});

  final MeterInfo meter;

  @override
  Widget build(BuildContext context) {
    final balance = meter.balance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        actions: [
          IconButton(
            icon: const Padding(
              padding: .symmetric(horizontal: 10),
              child: Icon(Icons.delete, color: Colors.grey),
            ),
            tooltip: "Remove Meter",
            onPressed: () {
              removeMeter(meter);
              colorPicker.add(meter.color);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          DataTableWidget(
            children: [
              tableRow("Account No", balance.accountNo),
              tableRow("Meter No", balance.meterNo),
              tableRow("Balance", "৳ ${balance.balance}"),
              tableRow(
                "Month Consumption",
                "${balance.currentMonthConsumption} kWh",
              ),
              tableRow("Reading Time", meter.formattedDate),
            ],
          ),
        ],
      ),
    );
  }
}
