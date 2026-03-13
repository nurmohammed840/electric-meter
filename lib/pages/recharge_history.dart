import 'package:desco_usage/app_state.dart';
import 'package:desco_usage/widgets/table_data.dart';
import 'package:flutter/material.dart';

class RechargeHistoryPage extends StatelessWidget {
  const RechargeHistoryPage({super.key, required this.meterRechargeHistory});

  final MeterRechargeHistory meterRechargeHistory;

  @override
  Widget build(BuildContext context) {
    final h = meterRechargeHistory.history;
    final chargeItems = h.chargeItems
        .where((item) => item.chargeAmount > 0)
        .map((item) => tableRow(item.chargeItemName, "৳ ${item.chargeAmount}"));

    return Scaffold(
      appBar: AppBar(title: const Text('Recharge Receipt')),
      body: ListView(
        children: [
          DataTableWidget(
            children: [
              tableRow("Account No", h.accountNo),
              tableRow("Meter No", h.meterNo),
              tableRow("Recharge Date", meterRechargeHistory.formattedDate),
              tableRow(
                "Total Amount",
                "৳ ${meterRechargeHistory.formattedBalance}",
              ),
              tableRow("Charge Amount", "৳ ${h.chargeAmount}"),
              tableRow("Energy Amount", "৳ ${h.energyAmount}"),
            ],
          ),
          const TableHeader(header: "Charges"),
          DataTableWidget(
            children: [
              ...chargeItems,
              tableRow("VAT", "৳ ${h.vat}"),
              tableRow("Rebate", "৳ ${h.rebate}"),
            ],
          ),
          const TableHeader(header: "Transaction Info"),
          DataTableWidget(
            children: [
              tableRow("Sequence", h.sequence),
              tableRow("Status", h.orderStatus),
              tableRow("Token", h.token),
              tableRow("Order ID", h.orderId),
              tableRow("Recharge Operator", h.rechargeOperator),
            ],
          ),
        ],
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key, required this.header});

  final String header;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .symmetric(vertical: 8),
        child: Text(
          header,
          style: const TextStyle(fontSize: 16, fontWeight: .bold),
        ),
      ),
    );
  }
}
