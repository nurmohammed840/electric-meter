import './tariff.dart';

class ResidentialTariff {
  ResidentialTariff();

  static final instance = ResidentialTariff();

  final double demandCharge = 42.00;

  TariffCategory category = TariffCategory.lowTensionA;

  final SlabRate lifeLine = SlabRate(start: 0, end: 50, price: 4.63);

  final slabs = [
    SlabRate(start: 1, end: 75, price: 5.26),
    SlabRate(start: 76, end: 200, price: 8.50),
    SlabRate(start: 201, end: 300, price: 9.10),
    SlabRate(start: 301, end: 400, price: 9.62),
    SlabRate(start: 401, end: 600, price: 15.01),
    SlabRate(start: 601, price: 17.35),
  ];

  double unitFromEnergyCost(double cost) {
    double remainingCost = cost;

    final lifeLineMaxCost = lifeLine.end! * lifeLine.price;
    if (remainingCost <= lifeLineMaxCost) {
      return remainingCost / lifeLine.price;
    }

    double unit = 0;

    for (final tariff in slabs) {
      double slabFrom = tariff.start;
      double slabTo =
          tariff.end ?? double.infinity; // if `to` is null, treat as infinite

      double slabUnits = (slabTo - slabFrom + 1);
      double slabCost = slabUnits * tariff.price;

      if (remainingCost > slabCost) {
        unit += slabUnits;
        remainingCost -= slabCost;
      } else {
        unit += remainingCost / tariff.price;
        break;
      }
    }
    return unit;
  }

  double energyCost(double units) {
    double cost = 0;
    double remaining = units;

    for (var tariff in slabs) {
      double slabFrom = tariff.start;
      double slabTo = tariff.end ?? units; // if `to` is null, treat as infinite

      double slabUnits = 0;
      if (remaining > 0) {
        // slabUnits = slabTo - slabFrom + 1;

        slabUnits = (remaining + slabFrom > slabTo)
            ? (slabTo - slabFrom + 1)
            : remaining;

        cost += slabUnits * tariff.price;

        // print(
        //   "slabUnits: $slabUnits * ${tariff.price} = ${slabUnits * tariff.price}; cost = $cost",
        // );

        remaining -= slabUnits;
      }
    }

    return cost;
  }
}

double calculateTotalBill(
  double energyCost, {
  double demand = 42,
  double load = 1,
  double vat = 0.05,
}) {
  double baseBill = energyCost + (demand * load);
  double vatAmount = baseBill * vat;
  return baseBill + vatAmount;
}
