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
      appBar: AppBar(title: const Text("Details")),
      body: Table(
        border: .all(color: Colors.grey),
        columnWidths: const {0: FlexColumnWidth(4), 1: FlexColumnWidth(6)},
        children: [
          tableRow("Account No", balance.accountNo),
          tableRow("Meter No", balance.meterNo),
          tableRow("Balance", "৳ ${balance.balance.toStringAsFixed(2)}"),
          tableRow("Month Consumption", "${balance.currentMonthConsumption.toStringAsFixed(2)} kWh"),
          tableRow("Reading Time", DateFormat('MMMM d').format(balance.readingTime.time())),
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
    );
  }

  TableRow tableRow(String title, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(padding: const EdgeInsets.all(8), child: Text(value ?? "-")),
      ],
    );
  }
}
