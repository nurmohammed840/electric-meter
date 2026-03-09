import 'package:desco_usage/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '/app_state.dart';

class ConsumptionScreen extends StatelessWidget {
  const ConsumptionScreen({super.key});

  @override
  Widget build(BuildContext _) {
    print("------------------");
    return Scaffold(
      appBar: appBar("Daily Consumption"),
      body: dailyConsumtions.watch(
        (_) => FutureBuilder(
          future: dailyConsumtions.value,
          builder: (_, data) {
            return Column(
              children: [
                ElevatedButton(
                  child: Text("Click"),
                  onPressed: () {
                    final len = data.data?.length ?? 0;
                    dailyConsumtions.set(
                      Future.value(List.generate(len + 1, (_) => 42)),
                    );
                  },
                ),
                Text("data ${data.data?.length}"),
              ],
            );
          },
        ),
      ),
    );
  }
}
