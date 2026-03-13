import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  const DataTableWidget({super.key, required this.children});

  final List<TableRow> children;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: .all(color: Colors.grey),
      columnWidths: const {0: FlexColumnWidth(4), 1: FlexColumnWidth(6)},
      children: children,
    );
  }
}

TableRow tableRow(String title, String value) {
  return TableRow(
    children: [
      Padding(
        padding: const .all(8),
        child: Text(title, style: const TextStyle(fontWeight: .bold)),
      ),
      Padding(padding: const .all(8), child: Text(value)),
    ],
  );
}

TableRow? optionalTableRow(String title, String? value) {
  if (value == null) return null;
  if (value.trim().isEmpty) return null;

  return TableRow(
    children: [
      Padding(
        padding: const .all(8),
        child: Text(title, style: const TextStyle(fontWeight: .bold)),
      ),
      Padding(padding: const .all(8), child: Text(value)),
    ],
  );
}
