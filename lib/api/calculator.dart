import './tariff.dart';

double calculateEnergyCost(int units, TariffProvider provider) {
  double cost = 0;
  int remaining = units;

  for (var tariff in provider.tariffs) {
    int slabFrom = tariff.range.from;
    int slabTo = tariff.range.to ?? units; // if `to` is null, treat as infinite

    // Calculate units in this slab
    int slabUnits = 0;
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
