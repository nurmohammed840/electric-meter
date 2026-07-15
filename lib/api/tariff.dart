final _tariffCodeRegExp = RegExp(r'LT-([A-Z]+\d*)', caseSensitive: false);
final _tariffCategoryRegExp = RegExp(r'Category-([A-Z])', caseSensitive: false);

class SlabRate {
  SlabRate({required this.price, required this.start, this.end});

  double start;
  double? end;

  double price;
}

class FixedRate {
  const FixedRate({
    required this.offPeak,
    required this.peak,
    this.superOffPeak,
  });

  final double? superOffPeak;
  final double offPeak;
  final double peak;
}

enum TariffCategory {
  lowTensionA,
  lowTensionE;

  String code() {
    return switch (this) {
      TariffCategory.lowTensionA => "LT-A",
      TariffCategory.lowTensionE => "LT-E",
    };
  }

  String type() {
    return switch (this) {
      TariffCategory.lowTensionA => "residential",
      TariffCategory.lowTensionE => "commercial",
    };
  }

  static TariffCategory? fromCode(String input) {
    final letters = _tariffCodeRegExp
        .firstMatch(input)
        ?.group(1)
        ?.toUpperCase();

    return switch (letters) {
      "A" => TariffCategory.lowTensionA,
      "E" => TariffCategory.lowTensionE,
      _ => null,
    };
  }

  static TariffCategory? fromCategorySolution(String input) {
    final letter = _tariffCategoryRegExp
        .firstMatch(input)
        ?.group(1)
        ?.toUpperCase();

    return switch (letter) {
      "A" => TariffCategory.lowTensionA,
      "E" => TariffCategory.lowTensionE,
      _ => null,
    };
  }
}

class CommercialTariff {
  final TariffCategory category = TariffCategory.lowTensionE;

  final double demandCharge = 90;
  final FixedRate rates = const FixedRate(offPeak: 13.82, peak: 18.43);
}
