import 'package:desco_usage/app_state.dart';
import 'package:desco_usage/colors.dart';
import 'package:desco_usage/components/optional.dart';
import 'package:desco_usage/widgets/loading_indicator.dart';
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
          const LoadingIndicatorWidget(),
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
          ConsumerInfoWidget(meter: meter),
        ],
      ),
    );
  }
}

class ConsumerInfoWidget extends StatelessWidget {
  const ConsumerInfoWidget({super.key, required this.meter});

  final MeterInfo meter;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
}
