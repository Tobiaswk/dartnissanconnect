import 'package:dartnissanconnect/src/nissanconnect_trip_detail.dart';

class NissanConnectTrip {
  DateTime date;
  String co2reductionKg;
  String milesPerKWh;
  String kilometersPerKWh;
  String kWhPerMiles;
  String kWhPerKilometers;
  String kWhUsed;
  String travelDistanceMiles;
  String travelDistanceKilometers;

  List<NissanConnectTripDetail> tripDetails = List();
}
