import 'package:flutter/material.dart';

class ColorPicker {
  const ColorPicker();
  static List<Color> colors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.grey,
    Colors.cyan,
    Colors.yellow,
    Colors.lime,
    Colors.indigo,
    Colors.teal,
    Colors.amber,
  ];

  Color next() {
    if (colors.isEmpty) {
      return Colors.deepOrange;
    }
    return colors.removeAt(0);
  }

  void add(Color color) {
    colors.insert(0, color);
  }
}

const colorPicker = ColorPicker();
