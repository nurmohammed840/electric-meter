import 'package:desco_usage/pages/recharge_history.dart';
import 'package:desco_usage/utils.dart';
import 'package:desco_usage/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '/app_state.dart';

final _once = OnceInit();

class RechargeHistoryScreen extends StatelessWidget {
  const RechargeHistoryScreen({super.key});

  static void onFocus() {
      loadRechargeHistorys(Duration(days: 90));
    _once.callAsync(() async {
    });
  }

  @override
  Widget build(BuildContext _) {
    return Scaffold(
      appBar: appBar("Recharge History"),
      body: rechargeHistorys.watch(
        (_) => FutureBuilder(
          future: rechargeHistorys.value,
          builder: (_, snapshot) {
            if (snapshot.connectionState == .waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            return ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, _) => const Padding(
                padding: .symmetric(horizontal: 16.0),
                child: Divider(color: Colors.grey, thickness: 0.5),
              ),
              itemBuilder: (_, index) =>
                  RechargeHistoryTile(meterRechargeHistory: data[index]),
            );
          },
        ),
      ),
    );
  }
}

class RechargeHistoryTile extends StatelessWidget {
  const RechargeHistoryTile({super.key, required this.meterRechargeHistory});

  final MeterRechargeHistory meterRechargeHistory;

  @override
  Widget build(BuildContext context) {
    final info = meterRechargeHistory.info;
    final history = meterRechargeHistory.history;

    return ListTile(
      leading: const Icon(Icons.electric_meter),
      iconColor: info.color,
      title: Text(
        history.accountNo,
        style: const TextStyle(
          fontWeight: .w500, // make title bold
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: .start,
        children: [
          Text("# ${history.meterNo}"),
          Text(meterRechargeHistory.formattedDate),
        ],
      ),
      trailing: Text(
        "৳ ${meterRechargeHistory.formattedBalance}", // show balance on the right
        style: const TextStyle(fontWeight: .bold, fontSize: 22),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RechargeHistoryPage(meterRechargeHistory: meterRechargeHistory),
          ),
        );
        // open details pagelater
      },
    );
  }
}
