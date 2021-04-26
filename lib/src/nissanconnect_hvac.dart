import 'package:intl/intl.dart';

class NissanConnectHVAC {
  late bool isRunning;
  late double cabinTemperature;
  DateTime? climateScheduled;

  NissanConnectHVAC(Map params) {
    var hvac = params['data']['attributes'];
    cabinTemperature = hvac['internalTemperature'];
    isRunning = hvac['hvacStatus'] != 'off';
    if (hvac['nextHvacStartDate'] != null) {
      climateScheduled = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
          .parse(hvac['nextHvacStartDate'], true)
          .toLocal();
    }
  }
}
