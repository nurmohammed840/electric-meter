import 'package:desco_usage/app_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Table(
            border: .all(color: Colors.grey),
            columnWidths: const {0: FlexColumnWidth(4), 1: FlexColumnWidth(6)},
            children: [
              tableRow("Account No", balance.accountNo),
              tableRow("Meter No", balance.meterNo),
              tableRow("Balance", "৳ ${balance.balance.toStringAsFixed(2)}"),
              tableRow(
                "Month Consumption",
                "${balance.currentMonthConsumption.toStringAsFixed(2)} kWh",
              ),
              tableRow(
                "Reading Time",
                DateFormat('MMMM d').format(balance.readingTime.time()),
              ),
              // tableRow("Customer Name", meter.customerName),
              // tableRow("Tariff", meter.tariffSolution),
              // tableRow("Contact No", meter.contactNo),
              // tableRow("Feeder Name", meter.feederName),
              // tableRow("Installation Address", meter.installationAddress),
              // tableRow("Installation Date", meter.installationDate?.toString()),
              // tableRow("Phase Type", meter.phaseType),
              // tableRow("Sanction Load", meter.sanctionLoad?.toString()),
              // tableRow("Meter Model", meter.meterModel),
              // tableRow("Transformer", meter.transformer),
              // tableRow("SD Name", meter.sdName),
            ],
          ),
        ],
      ),
    );
  }

  TableRow tableRow(String title, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const .all(8),
          child: Text(title, style: const TextStyle(fontWeight: .bold)),
        ),
        Padding(padding: const .all(8), child: Text(value ?? "-")),
      ],
    );
  }
}
