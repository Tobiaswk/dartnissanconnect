import 'package:dartnissanconnect/src/unit_calculator.dart';
import 'package:intl/intl.dart';

class NissanConnectStats {
  late DateTime date;
  late int tripsNumber;
  late String milesPerKWh;
  late String kilometersPerKWh;
  late String kWhPerMiles;
  late String kWhPerKilometers;
  late String kWhUsed;
  late String kWhGained;
  late String travelDistanceMiles;
  late String travelDistanceKilometers;
  late String travelSpeedAverageMph;
  late String travelSpeedAverageKmh;
  late Duration travelTime;

  NissanConnectStats(Map trip) {
    UnitCalculator unitCalculator = UnitCalculator();

    // consumedElectricity is in kilowatt not watt; thus multiply by 1000
    var consumedElectricity = trip['consumedElectricity'] * 1000;
    // gainedElectricity is in kilowatt not watt; thus multiply by 1000
    var gainedElectricity = trip['savedElectricity'] * 1000;

    this.tripsNumber = trip['tripsNumber'];
    this.milesPerKWh = unitCalculator.milesPerKWhPretty(
            consumedElectricity, trip['distance']) +
        ' mi/kWh';
    this.kWhPerMiles = unitCalculator.kWhPerMilesPretty(
            consumedElectricity, trip['distance']) +
        ' kWh/mi';
    this.kilometersPerKWh = unitCalculator.kilometersPerKWhPretty(
            consumedElectricity, trip['distance']) +
        ' km/kWh';
    this.kWhPerKilometers = unitCalculator.kWhPerKilometersPretty(
            consumedElectricity, trip['distance']) +
        ' kWh/km';
    this.kWhUsed = unitCalculator.WhtoKWhPretty(consumedElectricity) + ' kWh';
    this.kWhGained = unitCalculator.WhtoKWhPretty(gainedElectricity) + ' kWh';
    this.travelDistanceKilometers =
        unitCalculator.toKilometersPretty(trip['distance']) + ' km';
    this.travelDistanceMiles =
        unitCalculator.toMilesPretty(trip['distance']) + ' mi';
    this.travelTime = Duration(minutes: trip['duration']);
    this.travelSpeedAverageKmh = unitCalculator.averageSpeedKmhPretty(
            trip['distance'], travelTime.inMinutes) +
        ' km/h';
    this.travelSpeedAverageMph = unitCalculator.averageSpeedMphPretty(
            trip['distance'], travelTime.inMinutes) +
        ' mph';
    this.date =
        DateFormat("yyyy-MM-dd'T'H:m:s'Z'").parse(trip['firstTripStart']);
  }

  static List<NissanConnectStats> list(Map map) {
    var trips = map['data']['attributes']['summaries'];
    List<NissanConnectStats> result = [];
    for (Map trip in trips) {
      result.add(NissanConnectStats(trip));
    }
    return result;
  }
}
