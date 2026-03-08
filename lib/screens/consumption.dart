import 'package:desco_usage/app_state.dart';

import 'package:desco_usage/components/balance_pie_chart.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

class ConsumptionScreen extends AppScreen {
  const ConsumptionScreen({super.key});

  @override
  final title = "Consumption";

  @override
  Widget build(BuildContext context) {
    return BalancePieChart(meters: meterInfos.value);
  }
}
