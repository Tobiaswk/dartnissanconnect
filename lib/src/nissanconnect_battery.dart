import 'package:dartnissanconnect/src/unit_calculator.dart';
import 'package:intl/intl.dart';

enum ChargingSpeed { NONE, SLOW, NORMAL, FAST }

class NissanConnectBattery {
  NumberFormat numberFormat = NumberFormat('0');

  DateTime dateTime;
  ChargingSpeed chargingSpeed;
  bool isConnected = false;
  bool isCharging = false;
  String batteryPercentage;
  String
      battery12thBar; // Leaf using 12th bar system; present as 12ths; 5/12 etc.
  String cruisingRangeAcOffKm;
  String cruisingRangeAcOffMiles;
  String cruisingRangeAcOnKm;
  String cruisingRangeAcOnMiles;

  Duration timeToFullSlow;
  Duration timeToFullNormal;
  Duration timeToFullFast;
  String chargingkWLevelText;
  String chargingRemainingText;

  NissanConnectBattery(Map params) {
    UnitCalculator unitCalculator = UnitCalculator();

    var recs = params['data']['attributes'];
    this.dateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
        .parse(recs['lastUpdateTime'])
        .toLocal();
    this.chargingSpeed = ChargingSpeed.values[recs['chargePower'] ?? 0];
    this.isConnected = recs['chargeStatus'] != 0;
    this.isCharging = recs['chargeStatus'] != 0;
    this.batteryPercentage =
        NumberFormat('0.0').format(recs['batteryLevel']).toString() + '%';
    this.cruisingRangeAcOffKm =
        numberFormat.format(recs['rangeHvacOff'].toDouble()) + ' km';
    this.cruisingRangeAcOffMiles = numberFormat
            .format(unitCalculator.toMiles(recs['rangeHvacOff'].toDouble())) +
        ' mi';
    this.cruisingRangeAcOnKm =
        numberFormat.format(recs['rangeHvacOn'].toDouble()) + ' km';
    this.cruisingRangeAcOnMiles = numberFormat
            .format(unitCalculator.toMiles(recs['rangeHvacOn'].toDouble())) +
        ' mi';
    this.timeToFullSlow = Duration(minutes: recs['timeRequiredToFullSlow']);
    this.timeToFullNormal = Duration(minutes: recs['timeRequiredToFullNormal']);
    this.timeToFullFast = Duration(minutes: recs['timeRequiredToFullFast']);
    switch (this.chargingSpeed) {
      case ChargingSpeed.NONE:
        break;
      case ChargingSpeed.SLOW:
        chargingkWLevelText = 'slow charging';
        chargingRemainingText =
            '${timeToFullSlow.inHours} hrs ${timeToFullSlow.inMinutes} mins';
        break;
      case ChargingSpeed.NORMAL:
        chargingkWLevelText = 'normal charging';
        chargingRemainingText =
            '${timeToFullNormal.inHours} hrs ${timeToFullNormal.inMinutes} mins';
        break;
      case ChargingSpeed.FAST:
        chargingkWLevelText = 'fast charging';
        chargingRemainingText =
            '${timeToFullFast.inHours} hrs ${timeToFullFast.inMinutes} mins';
        break;
    }
  }
}
