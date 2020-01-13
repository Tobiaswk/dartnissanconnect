import 'package:intl/intl.dart';

class UnitCalculator {
  NumberFormat numberFormat00 = new NumberFormat('0.00');
  NumberFormat numberFormat0 = new NumberFormat('0');

  kWhPerKilometers(double consumptionWh, double distanceMeters) {
    return 1 / (toKilometers(distanceMeters) / (consumptionWh / 1000));
  }

  kWhPerKilometersPretty(double consumptionWh, double distanceMeters) {
    return format00(kWhPerKilometers(consumptionWh, distanceMeters));
  }

  kilometersPerKWh(double consumptionWh, double distanceMeters) {
    return toKilometers(distanceMeters) / (consumptionWh / 1000);
  }

  kilometersPerKWhPretty(double consumptionWh, double distanceMeters) {
    return format00(kilometersPerKWh(consumptionWh, distanceMeters));
  }

  kWhPerMiles(double consumptionWh, double distanceMeters) {
    return 1 / (toMiles(distanceMeters) / (consumptionWh / 1000));
  }

  kWhPerMilesPretty(double consumptionWh, double distanceMeters) {
    return format00(kWhPerMiles(consumptionWh, distanceMeters));
  }

  milesPerKWh(double consumptionWh, double distanceMeters) {
    return toMiles(distanceMeters) / (consumptionWh / 1000);
  }

  milesPerKWhPretty(double consumptionWh, double distanceMeters) {
    return format00(milesPerKWh(consumptionWh, distanceMeters));
  }

  WhtoKWh(double wh) {
    return wh / 1000;
  }

  WhtoKWhPretty(double wh) {
    return format00(WhtoKWh(wh));
  }

  toMiles(double distanceMeters) {
    return distanceMeters * 0.0006213712;
  }

  toMilesPretty(double distanceMeters) {
    return format0(toMiles(distanceMeters));
  }

  toKilometers(double distanceMeters) {
    return distanceMeters / 1000;
  }

  toKilometersPretty(double distanceMeters) {
    return format0(toKilometers(distanceMeters));
  }

  format00(double value) {
    return numberFormat00.format(value);
  }

  format0(double value) {
    return numberFormat0.format(value);
  }
}
