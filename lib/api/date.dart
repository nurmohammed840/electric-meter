import 'package:desco_usage/format.dart';

class Date {
  Date({required this.year, required this.month, required this.day});

  factory Date.from(DateTime time) =>
      Date(year: time.year, month: time.month, day: time.day);

  factory Date.now() => Date.from(DateTime.now());
  int year;
  int month;
  int day;

  DateTime time() => DateTime(year, month, day);
  String format() => dateFormatterDefault.format(time());

  @override
  String toString() {
    return "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }
}

class Month {
  Month({required this.year, required this.month});

  factory Month.from(DateTime time) =>
      Month(year: time.year, month: time.month);

  factory Month.now() => Month.from(DateTime.now());
  int year;
  int month;

  @override
  String toString() =>
      "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}}";
}
