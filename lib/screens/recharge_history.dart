import 'package:flutter/material.dart';

import '/components/error_snackbar.dart';
import '/pages/recharge_receipt.dart';
import '/signal.dart';
import '/utils.dart';
import '/widgets/app_bar.dart';
import '/app_state.dart';

import '../api/date.dart';
import '../components/center_widget.dart';

class RechargeHistoryScreen extends StatelessWidget {
  const RechargeHistoryScreen({super.key});

  static final _once = OnceInit();

  static Date to = Date.now();
  static Date from = Date.from(to.time().subtract(const Duration(days: 90)));

  static CreateState<Future<List<MeterRechargeReceipt>>> state = CreateState(
    Future.value([]),
  );

  static void loadRechargeHistorys(
    BuildContext context,
    Date from,
    Date to,
  ) async {
    Future<List<MeterRechargeReceipt>> load() async {
      final list = await showSnackBarOnError(
        context,
        () => fetchRechargeHistorys(from, to),
      );
      return list ?? [];
    }

    state.set(load());
  }

  static void onFocus(BuildContext context) {
    _once.callAsync(() async {
      loadRechargeHistorys(context, from, to);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar(
      "Recharge History",
      refrash: () {
        loadRechargeHistorys(context, from, to);
      },
      actionButton: IconButton(
        icon: const Icon(Icons.date_range),
        tooltip: "Date range",
        onPressed: () async {
          final start = from.time();
          final end = to.time();

          final dateRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDateRange: DateTimeRange(start: start, end: end),
          );

          if (dateRange == null) {
            return;
          }

          if (dateRange.start == start && dateRange.end == end) {
            return;
          }

          from = Date.from(dateRange.start);
          to = Date.from(dateRange.end);

          // if (context.mounted) loadRechargeHistorys(context, from, to);
          if (context.mounted) loadRechargeHistorys(context, from, to);
        },
      ),
    ),
    body: state.watch(
      (_) => FutureBuilder(
        future: state.value,
        builder: (_, snapshot) {
          if (snapshot.connectionState == .waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const CenterWidget(
              iconData: Icons.receipt_long,
              header: "No History",
              msg: "",
            );
          }
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

class RechargeHistoryTile extends StatelessWidget {
  const RechargeHistoryTile({super.key, required this.meterRechargeHistory});

  final MeterRechargeReceipt meterRechargeHistory;

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
                RechargeReceiptPage(meterRechargeReceipt: meterRechargeHistory),
          ),
        );
        // open details pagelater
      },
    );
  }
}
