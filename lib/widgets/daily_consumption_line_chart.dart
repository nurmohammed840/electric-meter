import 'dart:math' as math;

import 'package:desco_usage/api/customer.dart';
import 'package:desco_usage/api/date.dart';
import 'package:desco_usage/app_state.dart';
import 'package:desco_usage/components/optional.dart';
import 'package:desco_usage/format.dart';
import 'package:desco_usage/pages/settings.dart';
import 'package:desco_usage/signal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const monthNames = [
  "",
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

const hideTitle = AxisTitles(sideTitles: SideTitles(showTitles: false));

const borderColor = Color(0x77777777);
const border = Border(
  left: BorderSide(color: borderColor),
  bottom: BorderSide(color: borderColor),
);

class DailyConsumptionWidget extends StatelessWidget {
  const DailyConsumptionWidget({super.key, required this.meter});

  final MeterInfo meter;

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: meter.dailyConsumptions.get(),
    builder: (context, snapshot) {
      return snapshot.data.mapWidget((_, data) {
        final months = MontlyDailyConsumptionData.from(data);

        if (months.isEmpty) {
          return const SizedBox.shrink();
        }

        final selected = CreateState(months.length - 1);

        return Column(
          children: [
            const Padding(
              padding: .all(8.0),
              child: Text(
                "Daily Consumption",
                style: TextStyle(fontSize: 20, fontWeight: .bold),
              ),
            ),
            selected.watch(
              (_) => MonthChips(months: months, selected: selected),
            ),
            Padding(
              padding: const .only(right: 16, top: 16, bottom: 16),
              child: SizedBox(
                height: 250,
                child: selected.watch(
                  (_) =>
                      DailyConsumptionLineChart(month: months[selected.value]),
                ),
              ),
            ),
          ],
        );
      });
    },
  );
}

class MonthChips extends StatelessWidget {
  const MonthChips({super.key, required this.months, required this.selected});

  final CreateState<int> selected;
  final List<MontlyDailyConsumptionData> months;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (int i = 0; i < months.length; i++)
          ChoiceChip(
            // visualDensity: .compact,
            label: Text(monthNames[months[i].month]),
            selected: i == selected.value,
            onSelected: (val) {
              selected.set(i);
            },
          ),
      ],
    );
  }
}

class DailyConsumptionLineChart extends StatelessWidget {
  const DailyConsumptionLineChart({super.key, required this.month});

  final MontlyDailyConsumptionData month;

  @override
  Widget build(BuildContext context) {
    final data = month.data;
    final themeData = Theme.of(context);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: Settings.showDailyTakaDiff.value
            ? ceilMultipleOf(month.maxDailyConsumtionTakaDiff, 10)
            : nearestMultipleOf(
                math.max(
                  month.avgDailyConsumtionUnitDiff * 2,
                  month.maxDailyConsumtionUnitDiff,
                ),
                5,
              ),

        gridData: const FlGridData(
          drawHorizontalLine: true,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(border: border),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < data.length; i++)
                FlSpot(i.toDouble(), data[i].consumedUnitDiff),
            ],
            isCurved: true,
            barWidth: 2,
            color: Colors.blue,
            dotData: const FlDotData(show: true),
          ),

          if (Settings.showDailyTakaDiff.value)
            LineChartBarData(
              spots: [
                for (int i = 0; i < data.length; i++)
                  FlSpot(i.toDouble(), data[i].consumedTakaDiff),
              ],
              isCurved: true,
              barWidth: 2,
              color: Colors.red,
              dotData: const FlDotData(show: true),
            ),
        ],

        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: month.avgDailyConsumtionUnitDiff,
              color: themeData.brightness == .dark
                  ? Colors.white
                  : Colors.black,

              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(show: true, alignment: .topLeft),
            ),
          ],
        ),

        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            getTooltipColor: (touchedSpot) =>
                themeData.colorScheme.surfaceContainerHigh,

            getTooltipItems: (spots) => spots.map((spot) {
              final item = data[spot.spotIndex];
              return LineTooltipItem(
                spot.barIndex == 0
                    ? spot.y.toStringAsFixed(2)
                    : "${spot.y.round()} (${item.consumedTaka.round()})",

                TextStyle(
                  color: spot.bar.color,
                  fontWeight: .bold,
                  fontSize: 14,
                ),
                children: [
                  if (spot.barIndex == 0)
                    TextSpan(
                      text: "\n${dateFormatterAlt.format(item.date.time())}",
                      style: TextStyle(
                        fontSize: 12,
                        color: themeData.colorScheme.onSurface,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),

        titlesData: FlTitlesData(
          topTitles: hideTitle,
          rightTitles: hideTitle,
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30, // space for labels
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: data.length >= 21 ? 2 : 1,
              getTitlesWidget: (idx, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  data[idx.toInt()].date.day.toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double nearestMultipleOf(double value, double n) {
  return (value / n).round() * n;
}

double ceilMultipleOf(double value, double n) {
  return (value / n).ceil() * n;
}

class DailyConsumptionData {
  DailyConsumptionData({
    required this.consumedTaka,
    required this.consumedUnit,
    required this.consumedUnitDiff,
    required this.consumedTakaDiff,
    required this.date,
  });

  double consumedTaka;
  double consumedUnit;
  double consumedUnitDiff;
  double consumedTakaDiff;

  Date date;

  static Iterable<List<DailyConsumptionData>> from(
    List<DailyConsumption> data,
  ) sync* {
    List<DailyConsumptionData> thisMonth = [];

    for (int i = 1; i < data.length; i++) {
      final prev = data[i - 1];
      final curr = data[i];
      double consumedUnitDiff = curr.consumedUnit - prev.consumedUnit;
      double consumedTakaDiff = curr.consumedTaka - prev.consumedTaka;

      if (consumedTakaDiff < 0) {
        consumedUnitDiff = 0;
        consumedTakaDiff = curr.consumedTaka;
        yield thisMonth;
        thisMonth = [];
      }

      thisMonth.add(
        DailyConsumptionData(
          date: curr.date,
          consumedTaka: curr.consumedTaka,
          consumedUnit: curr.consumedUnit,
          consumedTakaDiff: consumedTakaDiff,
          consumedUnitDiff: consumedUnitDiff,
        ),
      );
    }
    yield thisMonth;
  }
}

class MontlyDailyConsumptionData {
  MontlyDailyConsumptionData({
    required this.month,
    required this.data,
    required this.avgDailyConsumtionUnitDiff,
    required this.maxDailyConsumtionUnitDiff,
    required this.maxDailyConsumtionTakaDiff,
  });

  int month;

  double avgDailyConsumtionUnitDiff;
  double maxDailyConsumtionUnitDiff;

  double maxDailyConsumtionTakaDiff;

  List<DailyConsumptionData> data;

  static List<MontlyDailyConsumptionData> from(List<DailyConsumption> data) {
    final List<MontlyDailyConsumptionData> array = [];
    for (final data in DailyConsumptionData.from(data)) {
      if (data.isEmpty) continue;

      double totalConsumtionUnitDiff = 0;
      double maxDailyConsumtionUnitDiff = 0;
      double maxDailyConsumtionTakaDiff = 0;

      for (var item in data) {
        totalConsumtionUnitDiff += item.consumedUnitDiff;
        maxDailyConsumtionUnitDiff = math.max(
          maxDailyConsumtionUnitDiff,
          item.consumedUnitDiff,
        );
        maxDailyConsumtionTakaDiff = math.max(
          maxDailyConsumtionTakaDiff,
          item.consumedTakaDiff,
        );
      }
      final avgDailyConsumtion = totalConsumtionUnitDiff / data.length;
      // data[0].consumedUnitDiff = avgDailyConsumtion;

      array.add(
        MontlyDailyConsumptionData(
          maxDailyConsumtionUnitDiff: maxDailyConsumtionUnitDiff,
          maxDailyConsumtionTakaDiff: maxDailyConsumtionTakaDiff,
          avgDailyConsumtionUnitDiff: avgDailyConsumtion,
          data: data,
          month: data[data.length ~/ 2].date.month,
        ),
      );
    }

    // for (final item in array) {
    //   print("==========");
    //   for (final val in item.data) {
    //     print(val.consumedUnit);
    //   }
    // }

    if (array.length > 1 && array[0].data.length < 7) {
      array.removeAt(0);
    }
    return array;
  }
}
