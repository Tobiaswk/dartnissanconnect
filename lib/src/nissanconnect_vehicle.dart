import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:dartnissanconnect/src/date_helper.dart';
import 'package:dartnissanconnect/src/nissanconnect_hvac.dart';
import 'package:dartnissanconnect/src/nissanconnect_location.dart';
import 'package:dartnissanconnect/src/nissanconnect_stats.dart';
import 'package:dartnissanconnect/src/nissanconnect_trips.dart';
import 'package:intl/intl.dart';

class NissanConnectVehicle {
  var _targetDateFormatter = DateFormat('yyyy-MM-dd');
  var _targetMonthFormatter = DateFormat('yyyyMM');
  var _executionTimeFormatter = DateFormat("yyyy-MM-dd'T'H:m:s'Z'");

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

  Future<bool> requestBatteryStatusRefresh() async {
    Map headers = Map<String, String>();
    headers['Host'] = 'application/vnd.api+json';
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/refresh-battery-status',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {'type': 'RefreshBatteryStatus'}
        });

    return response.statusCode == 200;
  }

  Future<NissanConnectBattery> requestBatteryStatus() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/battery-status',
        method: 'GET');

    return NissanConnectBattery(response.body);
  }

  Future<NissanConnectStats> requestDailyStatistics(DateTime date) async {
    var response = await session.requestWithRetry(
        endpoint: 'ecoDrive/vehicles/$vin/driveHistoryRecords',
        method: 'POST',
        params: {
          'displayCondition': {'TargetDate': _targetDateFormatter.format(date)}
        });

    return NissanConnectStats(
        response.body['personalData']['dateSummaryDetailInfo']);
  }

  Future<NissanConnectStats> requestMonthlyStatistics(DateTime month) async {
    var response = await session.requestWithRetry(
        endpoint: 'ecoDrive/vehicles/$vin/CarKarteGraphAllInfo',
        method: 'POST',
        params: {
          'dateRangeLevel': 'DAILY',
          'graphType': 'ALL',
          'targetMonth': _targetMonthFormatter.format(month)
        });

    return NissanConnectStats(
        response.body['carKarteGraphInfoResponseMonthPersonalData']
            ['monthSummaryCarKarteDetailInfo']);
  }

  Future<NissanConnectTrips> requestMonthlyStatisticsTrips(
      DateTime month) async {
    var response = await session.requestWithRetry(
        endpoint: 'electricusage/vehicles/$vin/detailpriceSimulatordata',
        method: 'POST',
        params: {'Targetmonth': _targetMonthFormatter.format(month)});
    return NissanConnectTrips(response.body);
  }

  Future<bool> requestChargingStart() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/charging-start',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {'type': 'ChargingStart', 'attributes': 'start'}
        });

    return response.statusCode == 200;
  }

  Future<bool> requestEngineStart() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/engine-start',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {'type': 'EngineStart', 'attributes': 'start'}
        });

    return response.statusCode == 200;
  }

  Future<bool> requestClimateControlOn(
      DateTime date, int temperatureTarget) async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/hvac-start',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {
            'type': 'HvacStart',
            'attributes': {
              'action': 'start',
              'targetTemperature': temperatureTarget,
              'startDateTime': formatDateWithTimeZone(DateTime.now()
                  .add(Duration(seconds: 5))) // must be in the future
            }
          }
        });

    return response.statusCode == 200;
  }

  Future<bool> requestClimateControlScheduledCancel() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/hvac-start',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {
            'type': 'HvacStart',
            'attributes': {
              'action': 'cancel',
              'targetTemperature': 21,
              'startDateTime': formatDateWithTimeZone(DateTime.now()
                  .add(Duration(seconds: 5))) // must be in the future
            }
          }
        });

    return response.statusCode == 200;
  }

  Future<bool> requestClimateControlOff() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/hvac-start',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {
            'type': 'HvacStart',
            'attributes': {
              'action': 'stop',
              'targetTemperature': 21,
              'startDateTime': formatDateWithTimeZone(DateTime.now()
                  .add(Duration(seconds: 5))) // must be in the future
            }
          }
        });

    return response.statusCode == 200;
  }

  Future<bool> requestClimateControlStatusUpdate() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/refresh-hvac-status',
        params: {
          'data': {'type': 'RefreshHvacStatus'}
        });
    return response.statusCode == 200;
  }

  Future<NissanConnectHVAC> requestClimateControlStatus() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/hvac-status',
        method: 'GET');

    return NissanConnectHVAC(response.body);
  }

  Future<bool> requestLocationRefresh() async {
    Map headers = Map<String, String>();
    headers['Host'] = 'application/vnd.api+json';
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/refresh-location',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {'type': 'RefreshLocation'}
        });

    return response.statusCode == 200;
  }

  Future<NissanConnectLocation> requestLocation() async {
    Map headers = Map<String, String>();
    headers['Host'] = 'application/vnd.api+json';
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/location',
        method: 'GET');

    return NissanConnectLocation(response.body['data']['attributes']);
  }
}
