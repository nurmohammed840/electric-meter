import 'package:desco_usage/pages/settings.dart';
import 'package:desco_usage/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

import '/components/error_snackbar.dart';
import '/signal.dart';
import '/widgets/app_bar.dart';
import '/components/optional.dart';
import '/app_state.dart';
import '/pages/details.dart';
import '/components/balance_pie_chart.dart';
import '/components/center_widget.dart';

class UsageScreen extends StatelessWidget {
  const UsageScreen({super.key});

  static final loadingIndicator = LoadingIndicator();

  static CreateState<Object?> error = CreateState(null);
  static Listenable usageEvent = Listenable.merge([error, meterInfos]);

  @override
  Widget build(BuildContext _) => Scaffold(
    appBar: appBar("Usage", actions: [UsageScreen.loadingIndicator]),
    body: Watch(
      signal: usageEvent,
      builder: (_) {
        if (meterInfos.value.isEmpty) {
          if (error.value != null) {
            return CenterWidget(
              iconData: Icons.wifi_off_rounded,
              header: "Connection Error",
              msg: errorMsg(error.value!),
              child: [
                loadingIndicator.state.watch(
                  (_) => TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                    onPressed: loadingIndicator.isLoading()
                        ? null
                        : AppInstance.store.loadAppData,
                  ),
                ),
              ],
            );
          }

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
            builder: (_) => const Padding(
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
      },
    ),
  );
}

class MeterList extends StatelessWidget {
  const MeterList({super.key, required this.meter});

  final MeterInfo meter;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.electric_meter),
    iconColor: meter.color,
    title: Text(
      meter.balance.accountNo,
      style: const TextStyle(
        fontWeight: .w500, // make title bold
      ),
    ),
    subtitle: Column(
      crossAxisAlignment: .start,
      children: [
        Text("# ${meter.balance.meterNo}"),
        Text("${meter.balance.currentMonthConsumption.round()} kWh"),
        Text(meter.formattedDate),
      ],
    ),
    trailing: Settings.lowBalanceThreshold.watch(
      (_) => Text(
        meter.balance.balance.toString(), // show balance on the right
        style: TextStyle(
          fontWeight: .bold,
          fontSize: 22,
          color: _getBalanceColor(
            meter.balance.balance,
            Settings.lowBalanceThreshold.value,
          ),
        ),
      ),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MeterDetailsPage(meter: meter)),
      );
    },
  );
}

Color? _getBalanceColor(double balance, RangeValues threshold) {
  if (balance <= threshold.start) {
    return Colors.redAccent[700]; // Critical
  } else if (balance <= threshold.end) {
    return Colors.orange; // Warning zone
  }
  return null; // Safe
}
