import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:dartnissanconnect/src/date_helper.dart';
import 'package:dartnissanconnect/src/nissanconnect_hvac.dart';
import 'package:dartnissanconnect/src/nissanconnect_location.dart';
import 'package:dartnissanconnect/src/nissanconnect_stats.dart';
import 'package:intl/intl.dart';

class NissanConnectVehicle {
  var _targetDateFormatter = DateFormat('yyyy-MM-dd');

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

  Future<NissanConnectStats> requestMonthlyStatistics() async {
    var start = DateTime(DateTime.now().year, DateTime.now().month, 1);
    var end = DateTime.now();
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/trip-history?start=${_targetDateFormatter.format(start)}&end=${_targetDateFormatter.format(end)}&type=${Period.MONTHLY.index}',
        method: 'GET');
    return NissanConnectStats(
        response.body['data']['attributes']['summaries'].last);
  }

  Future<NissanConnectStats> requestDailyStatistics() async {
    var start = DateTime.now();
    var end = start;
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/trip-history?start=${_targetDateFormatter.format(start)}&end=${_targetDateFormatter.format(end)}&type=${Period.DAILY.index}',
        method: 'GET');
    return NissanConnectStats(
        response.body['data']['attributes']['summaries'].last);
  }

  Future<List<NissanConnectStats>> requestMonthlyTripsStatistics(
      DateTime dateTime) async {
    var start, end;
    start = DateTime(dateTime.year, dateTime.month, 1);
    // If start is in the same month as 'now' we use the current date as end
    if (dateTime.month == DateTime.now().month) {
      end = DateTime.now();
    } else {
      // else find last day in month
      end = DateTime(dateTime.year, dateTime.month + 1, 1)
          .subtract(Duration(days: 1));
    }
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/trip-history?start=${_targetDateFormatter.format(start)}&end=${_targetDateFormatter.format(end)}&type=${Period.DAILY.index}',
        method: 'GET');
    return NissanConnectStats.list(response.body);
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
      DateTime date, int targetTemperature) async {
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
              'targetTemperature': targetTemperature,
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
