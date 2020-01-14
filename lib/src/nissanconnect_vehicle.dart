import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:dartnissanconnect/src/nissanconnect_location.dart';
import 'package:dartnissanconnect/src/nissanconnect_stats.dart';
import 'package:dartnissanconnect/src/nissanconnect_trips.dart';
import 'package:intl/intl.dart';

class NissanConnectVehicle {
  var _targetDateFormatter = new DateFormat('yyyy-MM-dd');
  var _targetMonthFormatter = new DateFormat('yyyyMM');
  var _executionTimeFormatter = new DateFormat("yyyy-MM-dd'T'H:m:s'Z'");

  NissanConnectSession session;
  var vin;
  var modelName;
  var nickname;

  NissanConnectVehicle(
    this.session,
    this.vin,
    this.modelName,
    this.nickname,
  );

  Future<bool> requestBatteryStatusUpdate() async {
    Map headers = Map<String, String>();
    headers["Host"] = 'application/vnd.api+json';
    var response = await session.requestWithRetry(
        endpoint:
            "https://alliance-platform-caradapter-prod.apps.eu.kamereon.io/car-adapter/v1/cars/$vin/actions/refresh-battery-status",
        additionalHeaders: <String, String>{
          "Content-Type": "application/vnd.api+json"
        },
        params: {
          "data": {"type": "RefreshBatteryStatus"}
        });

    return response.statusCode == 200;
  }

  Future<bool> requestBatteryStatus() async {
    var response = await session.requestWithRetry(
        endpoint:
            "https://alliance-platform-caradapter-prod.apps.eu.kamereon.io/car-adapter/v1/cars/$vin/actions/battery-status",
        method: 'GET');

    return response.statusCode == 200;
  }

  Future<NissanConnectStats> requestDailyStatistics(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: "ecoDrive/vehicles/$vin/driveHistoryRecords",
        method: "POST",
        params: {
          "displayCondition": {"TargetDate": _targetDateFormatter.format(date)}
        });

    return NissanConnectStats(
        response.body['personalData']['dateSummaryDetailInfo']);
  }

  Future<NissanConnectStats> requestMonthlyStatistics(DateTime month) async {
    var response = await session.requestWithRetry(
        endpoint: "ecoDrive/vehicles/$vin/CarKarteGraphAllInfo",
        method: "POST",
        params: {
          "dateRangeLevel": "DAILY",
          "graphType": "ALL",
          "targetMonth": _targetMonthFormatter.format(month)
        });

    return NissanConnectStats(
        response.body['carKarteGraphInfoResponseMonthPersonalData']
            ['monthSummaryCarKarteDetailInfo']);
  }

  Future<NissanConnectTrips> requestMonthlyStatisticsTrips(
      DateTime month) async {
    var response = await session.requestWithRetry(
        endpoint: "electricusage/vehicles/$vin/detailpriceSimulatordata",
        method: "POST",
        params: {"Targetmonth": _targetMonthFormatter.format(month)});
    return NissanConnectTrips(response.body);
  }

  Future<bool> requestChargingStart() async {
    var response = await session.requestWithRetry(
        endpoint: "battery/vehicles/$vin/remoteChargingRequest",
        method: "POST");

    return response.statusCode == 200;
  }

  Future<bool> requestClimateControlOn(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: "hvac/vehicles/$vin/activateHVAC",
        method: "POST",
        params: {
          "executionTime": _executionTimeFormatter.format(date.toUtc())
        });

    return response.body['messageDeliveryStatus'] == 'Success';
  }

  Future<bool> requestClimateControlScheduledCancel() async {
    var response = await session.requestWithRetry(
        endpoint: "hvacSchedule/vehicles/$vin/cancelHVACSchedule",
        method: "POST");

    return response.body['messageDeliveryStatus'] == 'Success';
  }

  Future<bool> requestClimateControlOff() async {
    var response = await session.requestWithRetry(
        endpoint: "hvac/vehicles/$vin/deactivateHVAC", method: "POST");

    return response.body['messageDeliveryStatus'] == 'Success';
  }

  Future<DateTime> requestClimateControlScheduled() async {
    var response = await session.requestWithRetry(
        endpoint: "hvacSchedule/vehicles/$vin/getHvacSchedule", method: "GET");

    return new DateFormat("yyyy-MM-dd'T'H:m:s")
        .parse(response.body['executeTime'], true)
        .toLocal();
  }

  Future<NissanConnectLocation> requestLocation(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: "vehicleLocator/vehicles/$vin/refreshVehicleLocator",
        method: "POST",
        params: {
          "acquiredDataUpperLimit": "1",
          "searchPeriod":
              "${new DateFormat('yyyyMMdd').format(date.subtract(new Duration(days: 30)))},${new DateFormat('yyyyMMdd').format(date)}",
          "serviceName": "MyCarFinderResult"
        });

    return new NissanConnectLocation(response.body);
  }
}
