import 'package:desco_usage/app_state.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Meter {
  final String meterNo;
  final double balance;

  Meter({required this.meterNo, required this.balance});
}

class BalancePieChart extends StatelessWidget {
  final List<MeterInfo> meters;

  const BalancePieChart({super.key, required this.meters});

  @override
  Widget build(BuildContext context) {
    final double totalBalance = meters.fold(
      0,
      (sum, meter) => sum + meter.balance.balance,
    );

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: List.generate(meters.length, (index) {
                final meter = meters[index];

                return PieChartSectionData(
                  value: meter.balance.balance,
                  color: meter.color,
                  title:
                      "${((meter.balance.balance / totalBalance) * 100).toStringAsFixed(1)}%",
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: .bold,
                    color: Colors.white,
                  ),
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),

        Padding(
          padding: const .symmetric(vertical: 16),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "Total Balance: ", // normal text
                  style: TextStyle(fontWeight: .normal, fontSize: 18),
                ),
                TextSpan(
                  text: totalBalance.toStringAsFixed(2), // bold balance
                  style: const TextStyle(fontWeight: .bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
