import 'package:intl/intl.dart';

class UnitCalculator {
  NumberFormat numberFormat00 = NumberFormat('0.00');
  NumberFormat numberFormat0 = NumberFormat('0');

  kWhPerKilometers(double consumptionWh, double distanceKilometers) {
    return 1 / (distanceKilometers / (consumptionWh / 1000));
  }

  kWhPerKilometersPretty(double consumptionWh, double distanceKilometers) {
    return format00(kWhPerKilometers(consumptionWh, distanceKilometers));
  }

  kilometersPerKWh(double consumptionWh, double distanceKilometers) {
    return distanceKilometers / (consumptionWh / 1000);
  }

  kilometersPerKWhPretty(double consumptionWh, double distanceKilometers) {
    return format00(kilometersPerKWh(consumptionWh, distanceKilometers));
  }

  kWhPerMiles(double consumptionWh, double distanceKilometers) {
    return 1 / (toMiles(distanceKilometers) / (consumptionWh / 1000));
  }

  kWhPerMilesPretty(double consumptionWh, double distanceKilometers) {
    return format00(kWhPerMiles(consumptionWh, distanceKilometers));
  }

  milesPerKWh(double consumptionWh, double distanceKilometers) {
    return toMiles(distanceKilometers) / (consumptionWh / 1000);
  }

  milesPerKWhPretty(double consumptionWh, double distanceKilometers) {
    return format00(milesPerKWh(consumptionWh, distanceKilometers));
  }

  WhtoKWh(double wh) {
    return wh / 1000;
  }

  WhtoKWhPretty(double wh) {
    return format00(WhtoKWh(wh));
  }

  toMiles(double distanceKilometers) {
    return distanceKilometers * 0.62137;
  }

  toMilesPretty(double distanceKilometers) {
    return format0(toMiles(distanceKilometers));
  }

  toKilometersPretty(double distanceKilometers) {
    return format0(distanceKilometers);
  }

  format00(double value) {
    return numberFormat00.format(value);
  }

  format0(double value) {
    return numberFormat0.format(value);
  }
}
