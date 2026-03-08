class Range {
  Range({required this.from, this.to});

  int from;
  int? to;
}

class Tariff {
  Tariff({required this.range, required this.price});

  Range range;
  double price;
}

abstract class TariffProvider {
  double get demandCharge;
  List<Tariff> get tariffs;
}

class LA implements TariffProvider {
  @override
  final double demandCharge = 42.00;

  @override
  final tariffs = [
    Tariff(range: Range(from: 1, to: 75), price: 5.26),
    Tariff(range: Range(from: 76, to: 200), price: 7.20),
    Tariff(range: Range(from: 201, to: 300), price: 7.59),
    Tariff(range: Range(from: 301, to: 400), price: 8.02),
    Tariff(range: Range(from: 401, to: 600), price: 12.67),
    Tariff(range: Range(from: 601), price: 14.61),
  ];
}
