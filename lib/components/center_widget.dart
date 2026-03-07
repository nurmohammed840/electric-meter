import 'package:flutter/material.dart';

class CenterWidget extends StatelessWidget {
  final IconData iconData;
  final String header;
  final String msg;

  const CenterWidget({
    super.key,
    required this.iconData,
    required this.header,
    required this.msg,
  });

  @override
  Widget build(_) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(iconData, color: Colors.grey, size: 48),
          const SizedBox(height: 16),
          Text(header, style: const TextStyle(fontSize: 18, fontWeight: .bold)),
          const SizedBox(height: 8),
          Text(
            msg,
            textAlign: .center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
