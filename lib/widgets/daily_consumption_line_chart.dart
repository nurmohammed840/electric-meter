import 'dart:math' as math;

import 'package:desco_usage/api/calculator.dart';
import 'package:desco_usage/api/tariff.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '/api/customer.dart';
import '/app_state.dart';
import '/components/optional.dart';
import '/format.dart';
import '/pages/settings.dart';
import '/signal.dart';

const borderColor = Color(0x77777777);

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
            const HeaderTitle(title: "Daily Consumption"),
            selected.watch(
              (_) => MonthChips(months: months, selected: selected),
            ),
            SizedGraph(
              builder: (_, constraints) => selected.watch(
                (_) => DailyConsumptionLineChart(
                  month: months[selected.value],
                  constraints: constraints,
                ),
              ),
            ),

            selected.watch(
              (_) => Optional(
                condition:
                    (months.length - 1) == selected.value &&
                    months[selected.value].tariffCategory ==
                        TariffCategory.lowTensionA,

                builder: (_) => Column(
                  children: [
                    const HeaderTitle(title: "Pradiction"),
                    SizedGraph(
                      builder: (_, constraints) => selected.watch(
                        (_) => PradictionGraph(
                          month: months[selected.value],
                          constraints: constraints,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      });
    },
  );
}

class HeaderTitle extends StatelessWidget {
  const HeaderTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .all(8.0),
    child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: .bold)),
  );
}

class SizedGraph extends StatelessWidget {
  const SizedGraph({super.key, required this.builder});

  final Widget? Function(BuildContext, BoxConstraints) builder;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .only(right: 16, top: 16, bottom: 16),
    child: LayoutBuilder(
      builder: (context, constraints) =>
          SizedBox(height: 250, child: builder(context, constraints)),
    ),
  );
}

class MonthChips extends StatelessWidget {
  const MonthChips({super.key, required this.months, required this.selected});

  final CreateState<int> selected;
  final List<MontlyDailyConsumptionData> months;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 8,
    children: [
      for (int i = 0; i < months.length; i++)
        ChoiceChip(
          label: Text(getMonthName(months[i].month)),
          selected: i == selected.value,
          onSelected: (val) {
            selected.set(i);
          },
        ),
    ],
  );
}

class PlotLineChart extends StatelessWidget {
  const PlotLineChart({
    super.key,
    required this.month,
    required this.constraints,
    required this.lineBarsData,
    required this.lineTouchData,
    this.maxY,
    this.showExtraLinesData = true,
  });

  final MontlyDailyConsumptionData month;
  final BoxConstraints constraints;

  final List<LineChartBarData> lineBarsData;
  final LineTouchData lineTouchData;

  final double? maxY;
  final bool showExtraLinesData;

  @override
  Widget build(BuildContext context) {
    final data = month.data;
    final themeData = Theme.of(context);

    final amountTitleInterval = computeTitleInterval(
      chartWidth: constraints.maxWidth,
      dataLength: data.length,
      labelWidth: 32,
    );

    final dayTitleInterval = computeTitleInterval(
      chartWidth: constraints.maxWidth,
      dataLength: data.length,
      labelWidth: 20,
    );

    ExtraLinesData? extraLinesData;

    if (showExtraLinesData) {
      extraLinesData = ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: month.avgDailyConsumtionUnitDiff,
            color: themeData.colorScheme.onSurface,
            strokeWidth: 1,
            dashArray: const [5, 5],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topLeft,
            ),
          ),
        ],
      );
    }

    final lineChartData = LineChartData(
      minX: 0,
      maxY: maxY,
      lineBarsData: lineBarsData,
      extraLinesData: extraLinesData,

      borderData: FlBorderData(
        border: Border(
          top: Settings.showAmountLabels.value
              ? const BorderSide(color: borderColor)
              : BorderSide.none,

          left: const BorderSide(color: borderColor),
          bottom: const BorderSide(color: borderColor),
        ),
      ),

      lineTouchData: lineTouchData,

      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles()),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (val, meta) {
              // Skip first and last (max)
              if (val <= 0 || val >= meta.max) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                meta: meta,
                child: Text(meta.formattedValue),
              );
            },
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: Settings.showAmountLabels.value,
            reservedSize: 25,
            interval: amountTitleInterval,
            getTitlesWidget: (idx, meta) {
              if (idx >= data.length - 1) return const SizedBox.shrink();
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  data[idx.toInt()].consumedTaka.round().toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: dayTitleInterval,
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

      gridData: FlGridData(
        drawVerticalLine: Settings.showAmountLabels.value,
        verticalInterval: amountTitleInterval,
      ),
    );

    return LineChart(lineChartData);
  }
}

class DailyConsumptionLineChart extends StatelessWidget {
  const DailyConsumptionLineChart({
    super.key,
    required this.month,
    required this.constraints,
  });

  final MontlyDailyConsumptionData month;
  final BoxConstraints constraints;

  @override
  Widget build(context) {
    final themeData = Theme.of(context);
    return PlotLineChart(
      month: month,
      constraints: constraints,
      maxY: Settings.showDailyTakaDiff.value
          ? ceilMultipleOf(month.maxDailyConsumtionTakaDiff, 10)
          : ceilMultipleOf(
              math.max(
                month.avgDailyConsumtionUnitDiff * 2,
                month.maxDailyConsumtionUnitDiff,
              ),
              5,
            ),

      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < month.data.length; i++)
              FlSpot(i.toDouble(), month.data[i].consumedUnitDiff),
          ],
          isCurved: true,
          barWidth: 2,
          color: Colors.blue,
          dotData: const FlDotData(show: true),
        ),

        if (Settings.showDailyTakaDiff.value)
          LineChartBarData(
            spots: [
              for (int i = 0; i < month.data.length; i++)
                FlSpot(i.toDouble(), month.data[i].consumedTakaDiff),
            ],
            isCurved: true,
            barWidth: 2,
            color: Colors.red,
            dotData: const FlDotData(show: true),
          ),
      ],

      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          getTooltipColor: (touchedSpot) =>
              themeData.colorScheme.surfaceContainerHigh,

          getTooltipItems: (spots) => spots.map((spot) {
            final item = month.data[spot.spotIndex];
            final unit = item.energyUnit()?.round();

            return LineTooltipItem(
              spot.barIndex == 0
                  ? unit != null
                        ? "${spot.y.toStringAsFixed(2)} ($unit)"
                        : spot.y.toStringAsFixed(2)
                  : "${spot.y.round()} (${item.consumedTaka.round()})",

              TextStyle(color: spot.bar.color, fontWeight: .bold, fontSize: 14),
              children: [
                if (spot.barIndex == 0)
                  TextSpan(
                    text: "\n${dateFormatterAlt.format(item.date)}",
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
    );
  }
}

class PradictionGraph extends StatelessWidget {
  const PradictionGraph({
    super.key,
    required this.month,
    required this.constraints,
  });

  final MontlyDailyConsumptionData month;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final monthData = month.data;
    final lastDay = monthData.last;
    final numOfRemainingDays = remainingDaysInMonth(lastDay.date);
    final lastDayUnit = lastDay.energyUnit();

    if (numOfRemainingDays == 0 || lastDayUnit == null) {
      return const SizedBox.shrink();
    }

    final avgUnitDiff = month.avgDailyConsumtionUnitDiff;
    var prevDayConsumedTaka = lastDay.consumedTaka;

    final upcomingData = List.generate(numOfRemainingDays, (idx) {
      final consumedUnit = lastDayUnit + ((idx + 1) * avgUnitDiff);
      final currentTaka = ResidentialTariff.instance.energyCost(consumedUnit);
      final consumedTakaDiff = currentTaka - prevDayConsumedTaka;

      prevDayConsumedTaka = currentTaka;

      return DailyConsumptionData(
        date: lastDay.date.add(Duration(days: idx + 1)),
        consumedTaka: currentTaka,
        consumedUnit: consumedUnit,
        consumedUnitDiff: avgUnitDiff,
        consumedTakaDiff: consumedTakaDiff,
        tariffCategory: TariffCategory.lowTensionA,
      );
    });

    return PlotLineChart(
      showExtraLinesData: false,
      constraints: constraints,
      month: MontlyDailyConsumptionData(
        data: upcomingData,
        month: month.month,
        avgDailyConsumtionUnitDiff: 0,
        maxDailyConsumtionUnitDiff: 0,
        maxDailyConsumtionTakaDiff: 0,
        tariffCategory: month.tariffCategory,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < upcomingData.length; i++)
              FlSpot(i.toDouble(), upcomingData[i].consumedTakaDiff),
          ],
          isCurved: true,
          barWidth: 2,
          color: Colors.blue,
          dotData: const FlDotData(show: true),
        ),
      ],
      lineTouchData: const LineTouchData(),
    );
  }
}

double computeTitleInterval({
  required double chartWidth,
  required int dataLength,
  required double labelWidth,
}) {
  final maxTitles = chartWidth ~/ labelWidth;
  return (dataLength / maxTitles).ceilToDouble();
}

double ceilMultipleOf(double value, double n) {
  return (value / n).ceil() * n;
}

int remainingDaysInMonth(DateTime date) {
  final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
  return lastDayOfMonth.day - date.day;
}

class DailyConsumptionData {
  DailyConsumptionData({
    required this.date,
    required this.consumedTaka,
    required this.consumedUnit,
    required this.consumedUnitDiff,
    required this.consumedTakaDiff,
    required this.tariffCategory,
  });

  DateTime date;
  double consumedTaka;
  double consumedUnit;
  double consumedUnitDiff;
  double consumedTakaDiff;

  TariffCategory? tariffCategory;

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
          tariffCategory: TariffCategory.fromCategorySolution(
            curr.tariffSolution ?? "",
          ),
        ),
      );
    }
    yield thisMonth;
  }

  double? energyUnit() {
    if (tariffCategory == TariffCategory.lowTensionA) {
      return ResidentialTariff.instance.unitFromEnergyCost(consumedTaka);
    }
    return null;
  }
}

class MontlyDailyConsumptionData {
  MontlyDailyConsumptionData({
    required this.month,
    required this.data,
    required this.avgDailyConsumtionUnitDiff,
    required this.maxDailyConsumtionUnitDiff,
    required this.maxDailyConsumtionTakaDiff,
    required this.tariffCategory,
  });

  int month;

  double avgDailyConsumtionUnitDiff;
  double maxDailyConsumtionUnitDiff;

  double maxDailyConsumtionTakaDiff;

  List<DailyConsumptionData> data;

  TariffCategory? tariffCategory;

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

      final itemCount = data.first.consumedUnitDiff == 0
          ? data.length - 1
          : data.length;

      final avgDailyConsumtion = totalConsumtionUnitDiff / itemCount;

      final dateOfMiddle = data[data.length ~/ 2];

      array.add(
        MontlyDailyConsumptionData(
          maxDailyConsumtionUnitDiff: maxDailyConsumtionUnitDiff,
          maxDailyConsumtionTakaDiff: maxDailyConsumtionTakaDiff,
          avgDailyConsumtionUnitDiff: avgDailyConsumtion,
          data: data,
          month: dateOfMiddle.date.month,
          tariffCategory: dateOfMiddle.tariffCategory,
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
