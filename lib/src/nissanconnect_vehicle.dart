import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:dartnissanconnect/src/date_helper.dart';
import 'package:dartnissanconnect/src/nissanconnect_hvac.dart';
import 'package:dartnissanconnect/src/nissanconnect_location.dart';
import 'package:dartnissanconnect/src/nissanconnect_stats.dart';
import 'package:intl/intl.dart';

enum Period { DAILY, MONTHLY, YEARLY }

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
    // This actually returns an ID; how to use the ID is not known yet
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/refresh-battery-status',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {'type': 'RefreshBatteryStatus'}
        });

    // Instead of somehow using the ID returned above we give the battery
    // status refresh some time to update
    await Future.delayed(Duration(seconds: 30));

    return response.statusCode == 200;
  }

  Future<NissanConnectBattery> requestBatteryStatus() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/battery-status',
        method: 'GET');

    return NissanConnectBattery(response.body);
  }

  Future<NissanConnectStats> requestMonthlyStatistics({DateTime month}) async {
    var start = DateTime(DateTime.now().year, DateTime.now().month, 1);
    var end = DateTime.now();
    if (start.month != month.month) {
      start = DateTime(month.year, month.month, 1);
      end =
          DateTime(month.year, month.month + 1, 1).subtract(Duration(days: 1));
    }
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
          'data': {
            'type': 'ChargingStart',
            'attributes': {'action': 'start'}
          }
        });

    return response.statusCode == 200;
  }

  Future<bool> requestChargingStop() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/charging-start',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {
            'type': 'ChargingStart',
            'attributes': {'action': 'stop'}
          }
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
              'startDateTime': formatDateWithTimeZone(
                  date.add(Duration(seconds: 5))) // must be in the future
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
            'attributes': {'action': 'cancel', 'targetTemperature': 21}
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

  Future<bool> requestClimateControlStatusRefresh() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/refresh-hvac-status',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
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
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/location',
        method: 'GET');

    return NissanConnectLocation(response.body['data']['attributes']);
  }
}
