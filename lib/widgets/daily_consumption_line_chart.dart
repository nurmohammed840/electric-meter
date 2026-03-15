import 'dart:math' as math;

import 'package:desco_usage/app_state.dart';
import 'package:desco_usage/components/optional.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const borderColor = Color(0x77777777);

const border = Border(
  left: BorderSide(color: borderColor),
  bottom: BorderSide(color: borderColor),
);

class DailyConsumptionWidget extends StatelessWidget {
  const DailyConsumptionWidget({super.key, required this.meter});

  final MeterInfo meter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: SizedBox(
        height: 200,
        child: DailyConsumptionLineChart(meter: meter),
      ),
    );
  }
}

class DailyConsumptionLineChart extends StatelessWidget {
  const DailyConsumptionLineChart({super.key, required this.meter});

  final MeterInfo meter;

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: meter.dailyConsumptions.get(),
    builder: (context, snapshot) {
      return snapshot.data.mapWidget((_, data) {
        final months = groupBy(
          data,
          (a, b) => (b.consumedTaka - a.consumedTaka) > 0,
        );

        final month = months.last;

        List<FlSpot> spots = [];

        double maxConsumtionDiff = 0;
        double totalDiff = 0;

        for (int i = 1; i < month.length; i++) {
          final old = month[i - 1].consumedUnit;
          final curr = month[i].consumedUnit;
          final diff = curr - old;

          maxConsumtionDiff = math.max(maxConsumtionDiff, diff);
          totalDiff += diff;

          spots.add(FlSpot(i.toDouble(), diff));
        }

        final avgDailyConsumtion = totalDiff / (month.length - 1);

        var hideTitles = const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        );

        return LineChart(
          LineChartData(
            minY: 0,
            maxY: nearestMultipleOf(
              math.max(avgDailyConsumtion * 2, maxConsumtionDiff),
              5,
            ),
            gridData: const FlGridData(
              drawHorizontalLine: true,
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(border: border),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 2,
                color: Colors.blue,
                dotData: const FlDotData(show: true),
              ),
            ],

            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: avgDailyConsumtion,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                  label: HorizontalLineLabel(show: true, alignment: .topLeft),
                ),
              ],
            ),

            titlesData: FlTitlesData(
              topTitles: hideTitles,
              rightTitles: hideTitles,
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, interval: 5),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final val = data[value.toInt()];

                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        val.date.day.toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      });
    },
  );
}

double nearestMultipleOf(double value, double n) {
  return (value / n).round() * n;
}

List<List<T>> groupBy<T>(List<T> items, bool Function(T a, T b) cond) {
  if (items.isEmpty) return [];

  List<List<T>> groups = [];
  List<T> curr = [items.first];

  for (int i = 1; i < items.length; i++) {
    T a = items[i - 1];
    T b = items[i];

    if (cond(a, b)) {
      curr.add(b);
    } else {
      groups.add(curr);
      curr = [b];
    }
  }
  groups.add(curr);
  return groups;
}
