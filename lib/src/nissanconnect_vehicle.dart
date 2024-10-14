import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:dartnissanconnect/src/date_helper.dart';
import 'package:dartnissanconnect/src/nissanconnect_hvac.dart';
import 'package:dartnissanconnect/src/nissanconnect_lock_status.dart';
import 'package:intl/intl.dart';

enum NissanConnectPeriod { DAILY, MONTHLY, YEARLY }

enum NissanConnectVehicleType { leaf, ariya, other }

class NissanConnectVehicle {
  var _targetDateFormatter = DateFormat('yyyy-MM-dd');

  NissanConnectSession session;
  Services services;
  String vin;
  String modelName;
  String nickname;
  String canGeneration;

  NissanConnectVehicle(
    this.session,
    this.services,
    this.vin,
    this.modelName,
    this.nickname,
    this.canGeneration,
  );

  hasService(int id) => services.hasService(id);

  NissanConnectVehicleType get type => switch (modelName) {
        'Ariya' => NissanConnectVehicleType.ariya,
        'Leaf' => NissanConnectVehicleType.leaf,
        _ => NissanConnectVehicleType.other,
      };

  Future<bool> requestBatteryStatusRefresh() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/refresh-battery-status',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {'type': 'RefreshBatteryStatus'}
        });

    return _actionIsCompletedPoll(actionId: response.body['data']['id']);
  }

  Future<NissanConnectBattery> requestBatteryStatus() async {
    switch (type) {
      case NissanConnectVehicleType.other:
      case NissanConnectVehicleType.leaf:
        return NissanConnectBattery.leaf((await session.requestWithRetry(
                endpoint:
                    '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/battery-status',
                method: 'GET'))
            .body);
      case NissanConnectVehicleType.ariya:
        return NissanConnectBattery.ariya((await session.requestWithRetry(
                endpoint:
                    '${session.settings['EU']['user_base_url']}v3/cars/$vin/battery-status?canGen=$canGeneration',
                method: 'GET'))
            .body);
    }
  }

  Future<NissanConnectStats> requestMonthlyStatistics(
      {required DateTime month}) async {
    var start = DateTime(DateTime.now().year, DateTime.now().month, 1);
    var end = DateTime.now();
    if (start.month != month.month) {
      start = DateTime(month.year, month.month, 1);
      end =
          DateTime(month.year, month.month + 1, 1).subtract(Duration(days: 1));
    }
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/trip-history?start=${_targetDateFormatter.format(start)}&end=${_targetDateFormatter.format(end)}&type=${NissanConnectPeriod.MONTHLY.index}',
        method: 'GET');
    return NissanConnectStats(
        response.body['data']['attributes']['summaries'].last);
  }

  Future<NissanConnectStats> requestDailyStatistics() async {
    var start = DateTime.now();
    var end = start;
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/trip-history?start=${_targetDateFormatter.format(start)}&end=${_targetDateFormatter.format(end)}&type=${NissanConnectPeriod.DAILY.index}',
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
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/trip-history?start=${_targetDateFormatter.format(start)}&end=${_targetDateFormatter.format(end)}&type=${NissanConnectPeriod.DAILY.index}',
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

  Future<bool> requestHorn({bool on = true, int? duration = 2}) async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/horn-lights',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {
            'type': 'HornLights',
            'attributes': {
              'action': _hornAndLightsAction(on: on),
              'duration': duration,
              'target': 'horn'
            }
          }
        });

    return response.statusCode == 200;
  }

  Future<bool> requestLights({bool on = true, int? duration = 2}) async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/horn-lights',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {
            'type': 'HornLights',
            'attributes': {
              'action': _hornAndLightsAction(on: on),
              'duration': duration,
              'target': 'lights'
            }
          }
        });

    return response.statusCode == 200;
  }

  Future<bool> requestHornAndLights({bool on = true, int? duration = 2}) async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/horn-lights',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {
            'type': 'HornLights',
            'attributes': {
              'action': _hornAndLightsAction(on: on),
              'duration': duration,
              'target': 'horn_lights'
            }
          }
        });

    return response.statusCode == 200;
  }

  Future<bool> requestLockUnlock(
      {bool lock = true, bool onlyDoors = false}) async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/lock-unlock',
        additionalHeaders: <String, String>{
          'Content-Type': 'application/vnd.api+json'
        },
        params: {
          'data': {
            'type': 'LockUnlock',
            'attributes': {
              'lock': '${lock ? 'lock' : 'unlock'}',
              'doorType': '${onlyDoors ? 'driver_s_door' : 'doors_hatch'}',
              'srp': ''
            }
          }
        });

    return response.statusCode == 200;
  }

  Future<NissanConnectLockStatus> requestLockStatus() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/lock-status',
        method: 'GET');

    return NissanConnectLockStatus(response.body);
  }

  Future<String> _requestUserId() async {
    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['user_adapter_base_url']}v1/users/current',
        method: 'GET');

    return response.body['userId'];
  }

  String _hornAndLightsAction({required bool on}) {
    return '${on ? 'start' : 'stop'}';
  }

  // Needs implementation
  _initiateSrp() async {
    var userId = await _requestUserId();

    // salt = 20 hex chars, verifier = 512 hex chars
    var salt = '0' * 20;
    var verifier = 'ABCDEFGH' * 50;

    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/srp-initiates',
        params: {
          'data': {
            'type': 'SrpInitiates',
            'attributes': {
              's': salt,
              'i': userId,
              'v': verifier,
            }
          }
        });

    return response.body;
  }

  // Needs implementation
  _validateSrp() async {
    var userId = await _requestUserId();

    // 512 hex chars
    var a = '';

    var response = await session.requestWithRetry(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/srp-sets',
        params: {
          'data': {
            'type': 'SrpSets',
            'attributes': {
              'i': userId,
              'a': a,
            }
          }
        });

    return response.body;
  }

  Future<bool> _actionIsCompletedPoll({required String actionId}) async {
    int pollRetries = 8;

    while (pollRetries-- > 0) {
      var response = await session.request(
        endpoint:
            '${session.settings['EU']['car_adapter_base_url']}v1/cars/$vin/actions/status?actionId=$actionId',
        method: 'GET',
      );

      if (response.statusCode == 200 &&
          response.body['data']?['attributes']?['status']?.toUpperCase() ==
              'COMPLETED') return true;

      /// We wait 15 seconds before polling action status again
      await Future.delayed(Duration(seconds: 15));
    }

    return false;
  }
}
