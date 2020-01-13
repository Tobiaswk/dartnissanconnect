import 'package:dartnissanconnect/src/unit_calculator.dart';
import 'package:intl/intl.dart';

class NissanConnectBattery {
  NumberFormat numberFormat = new NumberFormat('0');

  DateTime dateTime;
  int batteryLevelCapacity;
  int batteryLevel;
  bool isConnected = false;
  bool isCharging = false;
  String batteryPercentage;
  String
      battery12thBar; // Leaf using 12th bar system; present as 12ths; 5/12 etc.
  String cruisingRangeAcOffKm;
  String cruisingRangeAcOffMiles;
  String cruisingRangeAcOnKm;
  String cruisingRangeAcOnMiles;
  Duration timeToFullTrickle;
  Duration timeToFullL2;
  Duration timeToFullL2_6kw;
  String chargingkWLevelText;
  String chargingRemainingText;

  NissanConnectBattery(Map params) {
    UnitCalculator unitCalculator = new UnitCalculator();

    var recs = params["batteryRecords"];
    var bs = recs['batteryStatus'];
    this.dateTime = new DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
        .parse(recs['lastUpdatedDateAndTime'], true).toLocal();
    this.batteryLevelCapacity = bs['batteryCapacity'];
    this.batteryLevel = bs['batteryRemainingAmount'];
    this.isConnected = recs['pluginState'] != 'NOT_CONNECTED';
    this.isCharging = bs['batteryChargingStatus'] != 'NO';
    this.batteryPercentage = new NumberFormat('0.0')
            .format((this.batteryLevel * 100) / this.batteryLevelCapacity)
            .toString() +
        '%';
    // If SOC is available; use it
    if (bs['soc'] != null && bs['soc']['value'] != null) {
      int SOC = bs['soc']['value'];
      this.batteryPercentage =
          new NumberFormat('0.0').format(SOC).toString() + '%';
    }
    this.cruisingRangeAcOffKm = numberFormat
            .format(unitCalculator.toKilometers(recs['cruisingRangeAcOff'])) +
        ' km';
    this.cruisingRangeAcOffMiles = numberFormat
            .format(unitCalculator.toMiles(recs['cruisingRangeAcOff'])) +
        ' mi';
    this.cruisingRangeAcOnKm = numberFormat
            .format(unitCalculator.toKilometers(recs['cruisingRangeAcOn'])) +
        ' km';
    this.cruisingRangeAcOnMiles =
        numberFormat.format(unitCalculator.toMiles(recs['cruisingRangeAcOn'])) +
            ' mi';
    this.timeToFullTrickle = new Duration(hours: 0, minutes: 0);
    this.timeToFullL2 = new Duration(hours: 0, minutes: 0);
    this.timeToFullL2_6kw = new Duration(hours: 0, minutes: 0);
    if (recs['timeRequired'] != null) {
      this.timeToFullTrickle = new Duration(
          hours: recs['timeRequired']['hourRequiredToFull'] ?? 0,
          minutes: recs['timeRequired']['minutesRequiredToFull'] ?? 0);
    }
    if (recs['timeRequired200'] != null) {
      this.timeToFullL2 = new Duration(
          hours: recs['timeRequired200']['hourRequiredToFull'] ?? 0,
          minutes: recs['timeRequired200']['minutesRequiredToFull'] ?? 0);
    }
    if (recs['timeRequired200_6kW'] != null) {
      this.timeToFullL2_6kw = new Duration(
          hours: recs['timeRequired200_6kW']['hourRequiredToFull'] ?? 0,
          minutes: recs['timeRequired200_6kW']['minutesRequiredToFull'] ?? 0);
    }
    if (timeToFullTrickle.inHours != 0) {
      chargingkWLevelText = "left to charge at ~1kW";
      chargingRemainingText =
          "${timeToFullTrickle.inHours} hrs ${timeToFullTrickle.inMinutes} mins";
    } else if (timeToFullL2.inHours != 0) {
      chargingkWLevelText = "left to charge at ~3kW";
      chargingRemainingText =
          "${timeToFullL2.inHours} hrs ${timeToFullL2.inMinutes} mins";
    } else if (timeToFullL2_6kw.inHours != 0) {
      chargingkWLevelText = "left to charge at ~6kW";
      chargingRemainingText =
          "${timeToFullL2_6kw.inHours} hrs ${timeToFullL2_6kw.inMinutes} mins";
    }
  }
}
