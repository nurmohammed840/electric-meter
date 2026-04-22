import 'package:flutter/material.dart';

import '/app_state.dart';
import '/colors.dart';
import '/components/optional.dart';
import '/widgets/daily_consumption_line_chart.dart';
import '/pages/settings.dart';
import '/widgets/loading_indicator.dart';
import '/widgets/table_data.dart';

class MeterDetailsPage extends StatelessWidget {
  const MeterDetailsPage({super.key, required this.meter});

  final MeterInfo meter;

  @override
  Widget build(BuildContext context) {
    final balance = meter.balance;

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          dense: true,
          contentPadding: .zero,
          visualDensity: .compact,
          leading: const Icon(Icons.electric_meter),
          iconColor: meter.color,
          title: Text(
            balance.accountNo,
            style: const TextStyle(fontWeight: .bold),
          ),
          subtitle: Text(balance.meterNo),
        ),
        actions: [
          const LoadingIndicator(),
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
      body: ListView(
        children: [
          DataTableWidget(
            children: [
              tableRow("Balance", "৳ ${balance.balance}"),
              tableRow(
                "Consumption",
                "${balance.currentMonthConsumption.round()} kWh",
              ),
              tableRow("Reading Time", meter.formattedDate),
            ],
          ),
          if (Settings.showConsumerInfo.value) ConsumerInfoWidget(meter: meter),

          DailyConsumptionWidget(meter: meter),
        ],
      ),
    );
  }
}

class ConsumerInfoWidget extends StatelessWidget {
  const ConsumerInfoWidget({super.key, required this.meter});

  final MeterInfo meter;

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: meter.info.getOrShowSnackBarErr(context),
    builder: (_, snapshot) => snapshot.data.mapWidget(
      (_, data) => Column(
        children: [
          const TableHeader(header: "Consumer Information"),
          DataTableWidget(
            children: [
              ?optionalTableRow("Name", data.customerName),
              ?optionalTableRow("Contact", data.contactNo),
              ?optionalTableRow("Load", data.sanctionLoad?.toString()),
              ?optionalTableRow("Feeder", data.feederName),
              ?optionalTableRow(
                "Installation Address",
                data.installationAddress,
              ),
              ?optionalTableRow("S & D", data.sdName),
              ?optionalTableRow(
                "Installation Date",
                data.installationDate?.format(),
              ),
              ?optionalTableRow("Meter Model", data.meterModel),
              ?optionalTableRow("Phase Type", data.phaseType),
              ?optionalTableRow("Tariff", data.tariffSolution),
              ?optionalTableRow("Transformer", data.transformer),
            ],
          ),
        ],
      ),
    ),
  );
}
