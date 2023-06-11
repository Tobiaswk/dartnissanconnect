import 'package:dartnissanconnect/src/unit_calculator.dart';
import 'package:intl/intl.dart';

enum ChargingSpeed { NONE, SLOW, NORMAL, FAST, FASTEST }

class NissanConnectBattery {
  late DateTime dateTime;
  late ChargingSpeed chargingSpeed;
  bool isConnected = false;
  bool isCharging = false;
  late String batteryPercentage;
  late String cruisingRangeAcOffKm;
  late String cruisingRangeAcOffMiles;
  late String cruisingRangeAcOnKm;
  late String cruisingRangeAcOnMiles;

  late Duration timeToFullSlow;
  late Duration timeToFullNormal;
  late Duration timeToFullFast;
  String? chargingkWLevelText;
  String? chargingRemainingText;

  NissanConnectBattery(Map params) {
    UnitCalculator unitCalculator = UnitCalculator();

    var recs = params['data']['attributes'];
    // For reasons unknown the lastUpdateTime sometimes includes
    // seconds and sometimes not
    try {
      this.dateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
          .parse(recs['lastUpdateTime'], true)
          .toLocal();
    } catch (e) {
      this.dateTime = DateFormat("yyyy-MM-dd'T'HH:mm'Z'")
          .parse(recs['lastUpdateTime'], true)
          .toLocal();
    }
    this.chargingSpeed = ChargingSpeed.values[recs['chargePower'] ?? 0];
    this.isConnected = recs['plugStatus'] != 0;
    this.isCharging = recs['chargeStatus'] != 0;
    this.batteryPercentage =
        NumberFormat('0.0').format(recs['batteryLevel']).toString() + '%';
    this.cruisingRangeAcOffKm =
        unitCalculator.toKilometersPretty(recs['rangeHvacOff'].toDouble()) +
            ' km';
    this.cruisingRangeAcOffMiles =
        unitCalculator.toMilesPretty(recs['rangeHvacOff'].toDouble()) + ' mi';
    this.cruisingRangeAcOnKm =
        unitCalculator.toKilometersPretty(recs['rangeHvacOn'].toDouble()) +
            ' km';
    this.cruisingRangeAcOnMiles =
        unitCalculator.toMilesPretty(recs['rangeHvacOn'].toDouble()) + ' mi';
    this.timeToFullSlow = Duration(minutes: recs['timeRequiredToFullSlow']);
    this.timeToFullNormal = Duration(minutes: recs['timeRequiredToFullNormal']);
    this.timeToFullFast = Duration(minutes: recs['timeRequiredToFullFast']);
    switch (this.chargingSpeed) {
      case ChargingSpeed.NONE:
        break;
      case ChargingSpeed.SLOW:
        chargingkWLevelText = 'slow charging';
        chargingRemainingText =
            '${timeToFullSlow.inHours} hrs ${timeToFullSlow.inMinutes % 60} mins';
        break;
      case ChargingSpeed.NORMAL:
        chargingkWLevelText = 'normal charging';
        chargingRemainingText =
            '${timeToFullNormal.inHours} hrs ${timeToFullNormal.inMinutes % 60} mins';
        break;
      case ChargingSpeed.FAST:
      case ChargingSpeed.FASTEST:
        chargingkWLevelText = 'fast charging';
        chargingRemainingText =
            '${timeToFullFast.inHours} hrs ${timeToFullFast.inMinutes % 60} mins';
        break;
    }
  }
}
