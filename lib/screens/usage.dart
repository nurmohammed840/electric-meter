import 'package:desco_usage/api/customer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'utils.dart';

import '/app_state.dart';
import '/components/balance_pie_chart.dart';
import '/components/center_widget.dart';

class UsageScreen extends AppScreen {
  const UsageScreen({super.key});

  @override
  final title = "Usage";

  @override
  Widget build(BuildContext context) {
    return meterInfos.watch((_) {
      if (meterInfos.value.isEmpty) {
        return const CenterWidget(
          iconData: Icons.electric_meter_outlined,
          header: "No Meter Found",
          msg: "",
        );
      }

      if (meterInfos.value.length == 1) {
        final meter = meterInfos.value[0].balance;
        final color = meterInfos.value[0].color;
        return ListView(
          children: [MeterList(meter: meter, color: color)],
        );
      }

      return ListView.separated(
        itemCount: meterInfos.value.length + 1,
        separatorBuilder: (_, index) => index == 0
            ? const SizedBox.shrink()
            : const Padding(
                padding: .symmetric(horizontal: 16.0),
                child: Divider(color: Colors.grey, thickness: 0.5),
              ),
        itemBuilder: (_, index) {
          if (index == 0) {
            return BalancePieChart(meters: meterInfos.value);
          }
          index -= 1;
          final meter = meterInfos.value[index].balance;
          final color = meterInfos.value[index].color;

          return MeterList(meter: meter, color: color);
        },
      );
    });
  }
}

class MeterList extends StatelessWidget {
  const MeterList({super.key, required this.meter, required this.color});

  final Balance meter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.electric_meter),
      title: Text(
        meter.accountNo,
        style: const TextStyle(
          fontWeight: FontWeight.w500, // make title bold
        ),
      ),
      // subtitle: Text(balance.meterNo),
      subtitle: Column(
        crossAxisAlignment: .start,
        children: [
          Text("# ${meter.meterNo}"),
          Text("${meter.currentMonthConsumption.toStringAsFixed(2)} kWh"),
          Text(DateFormat('MMMM d').format(meter.readingTime.time())),
        ],
      ),
      trailing: Text(
        meter.balance.toStringAsFixed(2), // show balance on the right
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      iconColor: color,
      onTap: () => {},
    );
  }
}
