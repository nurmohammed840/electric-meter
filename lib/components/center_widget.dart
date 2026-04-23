import 'package:flutter/material.dart';

class CenterWidget extends StatelessWidget {
  const CenterWidget({
    super.key,
    required this.iconData,
    required this.header,
    required this.msg,
    this.child = const [],
  });

  final IconData iconData;
  final String header;
  final String msg;

  final List<Widget> child;

  @override
  Widget build(_) => Center(
    child: Column(
      mainAxisAlignment: .center,
      children: [
        Icon(iconData, color: Colors.grey, size: 48),
        const SizedBox(height: 16),
        Text(header, style: const TextStyle(fontSize: 18, fontWeight: .bold)),
        Padding(
          padding: const .symmetric(vertical: 8),
          child: Text(
            msg,
            textAlign: .center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),

        ...child,
      ],
    ),
  );
}
