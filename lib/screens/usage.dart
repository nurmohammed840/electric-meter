import 'package:desco_usage/components/optional.dart';
import 'package:desco_usage/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '/app_state.dart';
import '/pages/details.dart';
import '/components/balance_pie_chart.dart';
import '/components/center_widget.dart';

class UsageScreen extends StatelessWidget {
  const UsageScreen({super.key});

  @override
  Widget build(BuildContext _) {
    return Scaffold(
      appBar: appBar("Usage"),
      body: meterInfos.watch((_) {
        if (meterInfos.value.isEmpty) {
          return const CenterWidget(
            iconData: Icons.electric_meter_outlined,
            header: "No Meter Found",
            msg: "",
          );
        }

        if (meterInfos.value.length == 1) {
          return ListView(children: [MeterList(meter: meterInfos.value[0])]);
        }

        return ListView.separated(
          itemCount: meterInfos.value.length + 1,
          separatorBuilder: (_, index) => Optional(
            condition: index > 0,
            child: const Padding(
              padding: .symmetric(horizontal: 16.0),
              child: Divider(color: Colors.grey, thickness: 0.5),
            ),
          ),
          itemBuilder: (_, index) {
            if (index == 0) {
              return BalancePieChart(meters: meterInfos.value);
            }
            return MeterList(meter: meterInfos.value[index - 1]);
          },
        );
      }),
    );
  }
}

class MeterList extends StatelessWidget {
  const MeterList({super.key, required this.meter});

  final MeterInfo meter;

  @override
  Widget build(BuildContext context) {
    final balance = meter.balance;
    return ListTile(
      leading: const Icon(Icons.electric_meter),
      iconColor: meter.color,
      title: Text(
        balance.accountNo,
        style: const TextStyle(
          fontWeight: .w500, // make title bold
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: .start,
        children: [
          Text("# ${balance.meterNo}"),
          Text("${balance.currentMonthConsumption} kWh"),
          Text(meter.formattedDate),
        ],
      ),
      trailing: Text(
        balance.balance.toString(), // show balance on the right
        style: const TextStyle(fontWeight: .bold, fontSize: 22),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeterDetailsPage(meter: meter),
          ),
        );
      },
    );
  }
}
