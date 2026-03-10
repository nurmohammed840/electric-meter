import 'package:desco_usage/utils.dart';
import 'package:desco_usage/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '/app_state.dart';

final _once = OnceInit();



class ConsumptionScreen extends StatelessWidget {
  const ConsumptionScreen({super.key});

  static void loadData() {
    _once.callAsync(() async {
      
    });
  }

  @override
  Widget build(BuildContext _) {
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
