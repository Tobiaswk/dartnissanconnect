import 'dart:async';
import 'dart:convert';

import 'package:dartnissanconnect/src/nissanconnect_response.dart';
import 'package:dartnissanconnect/src/nissanconnect_vehicle.dart';
import 'package:http/http.dart' as http;

class Services {
  static final int BREAKDOWN_ASSISTANCE_CALL = 1;
  static final int SVT_WITH_VEHICLE_BLOCKAGE = 10;
  static final int MAINTENANCE_ALERT = 101;
  static final int VEHICLE_SOFTWARE_UPDATES = 107;
  static final int MY_CAR_FINDER = 12;
  static final int MIL_ON_NOTIFICATION = 15;
  static final int VEHICLE_HEALTH_REPORT = 18;
  static final int ADVANCED_CAN = 201;
  static final int VEHICLE_STATUS_CHECK = 202;
  static final int LOCK_STATUS_CHECK = 2021;
  static final int NAVIGATION_FACTORY_RESET = 208;
  static final int MESSAGES_TO_THE_VEHICLE = 21;
  static final int VEHICLE_DATA = 2121;
  static final int VEHICLE_DATA_2 = 2122;
  static final int VEHICLE_WIFI = 213;
  static final int ADVANCED_VEHICLE_DIAGNOSTICS = 215;
  static final int NAVIGATION_MAP_UPDATES = 217;
  static final int VEHICLE_SETTINGS_TRANSFER = 221;
  static final int LAST_MILE_NAVIGATION = 227;
  static final int GOOGLE_STREET_VIEW = 229;
  static final int GOOGLE_SATELITE_VIEW = 230;
  static final int DYNAMIC_EV_ICE_RANGE = 232;
  static final int ECO_ROUTE_CALCULATION = 233;
  static final int CO_PILOT = 234;
  static final int DRIVING_JOURNEY_HISTORY = 235;
  static final int NISSAN_RENAULT_BROADCASTS = 241;
  static final int ONLINE_PARKING_INFO = 243;
  static final int ONLINE_RESTAURANT_INFO = 244;
  static final int ONLINE_SPEED_RESTRICTION_INFO = 245;
  static final int WEATHER_INFO = 246;
  static final int VEHICLE_ACCESS_TO_EMAIL = 248;
  static final int VEHICLE_ACCESS_TO_MUSIC = 249;
  static final int VEHICLE_ACCESS_TO_CONTACTS = 262;
  static final int APP_DOOR_LOCKING = 27;
  static final int GLONASS = 276;
  static final int ZONE_ALERT = 281;
  static final int SPEEDING_ALERT = 282;
  static final int SERVICE_SUBSCRIPTION = 284;
  static final int PAY_HOW_YOU_DRIVE = 286;
  static final int CHARGING_SPOT_INFO = 288;
  static final int FLEET_ASSET_INFORMATION = 29;
  static final int CHARGING_SPOT_INFO_COLLECTION = 292;
  static final int CHARGING_START = 299;
  static final int CHARGING_STOP = 303;
  static final int INTERIOR_TEMP_SETTINGS = 307;
  static final int CLIMATE_ON_OFF_NOTIFICATION = 311;
  static final int CHARGING_SPOT_SEARCH = 312;
  static final int PLUG_IN_REMINDER = 314;
  static final int CHARGING_STOP_NOTIFICATION = 317;
  static final int BATTERY_STATUS = 319;
  static final int BATTERY_HEATING_NOTIFICATION = 320;
  static final int VEHICLE_STATE_OF_CHARGE_PERCENT = 322;
  static final int BATTERY_STATE_OF_HEALTH_PERCENT = 323;
  static final int PAY_AS_YOU_DRIVE = 34;
  static final int DRIVING_ANALYSIS = 340;
  static final int CO2_GAS_SAVINGS = 341;
  static final int ELECTRICITY_FEE_CALCULATION = 342;
  static final int CHARGING_CONSUMPTION_HISTORY = 344;
  static final int BATTERY_MONITORING = 345;
  static final int BATTERY_DATA = 347;
  static final int APP_BASED_NAVIGATION = 35;
  static final int CHARGING_SPOT_UPDATES = 354;
  static final int RECHARGEABLE_AREA = 358;
  static final int NO_CHARGING_SPOT_INFO = 359;
  static final int EV_RANGE = 360;
  static final int CLIMATE_ON_OFF = 366;
  static final int ONLINE_FUEL_STATION_INFO = 367;
  static final int DESTINATION_SEND_TO_CAR = 37;
  static final int ECALL = 4;
  static final int GOOGLE_PLACES_SEARCH = 40;
  static final int PREMIUM_TRAFFIC = 43;
  static final int AUTO_COLLISION_NOTIFICATION_ACN = 6;
  static final int THEFT_BURGLAR_NOTIFICATION_VEHICLE = 7;
  static final int ECO_CHALLENGE = 721;
  static final int ECO_CHALLENGE_FLEET = 722;
  static final int MOBILE_INFORMATION = 74;
  static final int URL_PRESET_ON_VEHICLE = 77;
  static final int ASSISTED_DESTINATION_SETTING = 78;
  static final int CONCIERGE = 79;
  static final int PERSONAL_DATA_SYNC = 80;
  static final int THEFT_BURGLAR_NOTIFICATION_APP = 87;
  static final int STOLEN_VEHICLE_TRACKING_SVT = 9;
  static final int REMOTE_ENGINE_START = 96;
  static final int HORN_AND_LIGHTS = 97;
  static final int CURFEW_ALERT = 98;
  static final int TEMPERATURE = 2042;
  static final int VALET_PARKING_CALL = 401;
  static final int PANIC_CALL = 406;

  var _services;

  Services(this._services);

  bool hasService(int id) => _services.any((service) =>
      service['id'] == id && service['activationState'] == 'ACTIVATED');
}

class NissanConnectSession {
  Map settings = <String, Map>{
    'EU': <String, String>{
      'client_id': 'a-ncb-prod-android', // CLIENT_ID_V2_EU_PROD
      'client_secret':
          '3LBs0yOx2XO-3m4mMRW27rKeJzskhfWF0A8KUtnim8i/qYQPl8ZItp3IaqJXaYj_', // CLIENT_SECRET_V2_EU_PROD
      'scope': 'openid profile vehicles', // API_SCOPE_V2_EU_PROD
      'auth_base_url':
          'https://prod.eu.auth.kamereon.org/kauth/', // OAUTH_AUTHORIZATION_BASE_URL_V2_EU_PROD
      'realm':
          'a-ncb-prod', // OAUTH_REALM_DEFAULT_V2_EU_PROD CLIENT_ID_V2_EU_PROD
      'redirect_uri': 'org.kamereon.service.nci:/oauth2redirect',
      'car_adapter_base_url': // carAdapter_eu_prod
          'https://alliance-platform-caradapter-prod.apps.eu.kamereon.io/car-adapter/',
      'user_adapter_base_url': // userAdapter_eu_prod
          'https://alliance-platform-usersadapter-prod.apps.eu.kamereon.io/user-adapter/',
      'user_base_url':
          'https://nci-bff-web-prod.apps.eu.kamereon.io/bff-web/' // bffWeb_eu_prod
    }
  };

  var API_VERSION = 'protocol=1.0,resource=2.1';
  var SRP_KEY =
      'D5AF0E14718E662D12DBB4FE42304DF5A8E48359E22261138B40AA16CC85C76A11B43200A1EECB3C9546A262D1FBD51ACE6FCDE558C00665BBF93FF86B9F8F76AA7A53CA74F5B4DFF9A4B847295E7D82450A2078B5A28814A7A07F8BBDD34F8EEB42B0E70499087A242AA2C5BA9513C8F9D35A81B33A121EEF0A71F3F9071CCD';

  bool debug;
  List<String> debugLog = [];

  var username;
  var password;
  var bearerToken;

  late NissanConnectVehicle vehicle;
  late List<NissanConnectVehicle> vehicles;

  NissanConnectSession({this.debug = false});

  Future<NissanConnectResponse> requestWithRetry(
      {required String endpoint,
      String method = 'POST',
      Map<String, String>? additionalHeaders,
      Map? params}) async {
    NissanConnectResponse response = await request(
        endpoint: endpoint,
        method: method,
        additionalHeaders: additionalHeaders,
        params: params);

    if (response.statusCode >= 400) {
      _print('Signing in and trying request again: $response');

      await login(username: username, password: password);

      response = await request(
          endpoint: endpoint,
          method: method,
          additionalHeaders: additionalHeaders,
          params: params);
    }
    return response;
  }

  Future<NissanConnectResponse> request(
      {required String endpoint,
      String method = 'POST',
      Map<String, String>? additionalHeaders,
      Map? params}) async {
    _print('Invoking NissanConnect/Kamereon API: $endpoint');
    _print('Params: $params');

    Map<String, String> headers = Map();

    if (bearerToken != null) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    _print('Headers: $headers');

    http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(Uri.parse(endpoint), headers: headers);
        break;
      default:
        response = await http.post(Uri.parse(endpoint),
            headers: headers, body: json.encode(params));
    }

    dynamic jsonData;
    try {
      jsonData = json.decode(response.body);
      _print('Result: $jsonData');
    } catch (e) {
      _print('JSON decoding failed!');
    }

    return NissanConnectResponse(
        response.statusCode, response.headers, jsonData);
  }

  Future<NissanConnectVehicle> login(
      {required String username, required String password}) async {
    this.username = username;
    this.password = password;
    this.bearerToken = null;

    /// The Referer to this POST; https://prod.eu.auth.kamereon.org/kauth/XUI/?realm=/a-ncb-prod&goto=https://prod.eu.auth.kamereon.org/kauth/oauth2/a-ncb-prod/authorize?client_id=a-ncb-prod-android&redirect_uri=org.kamereon.service.nci%3A%2Foauth2redirect&response_type=code&scope=openid%20profile%20vehicles&state=af0ifjsldkj&nonce=sdfdsfez
    /// This Referer opens in a web view when you try to login with the official app
    /// We first get the authId used in the next POST (which is fetched automatically in web view using the above Referer)
    NissanConnectResponse response = await request(
        endpoint:
            '${settings['EU']['auth_base_url']}json/realms/root/realms/${settings['EU']['realm']}/authenticate',
        additionalHeaders: <String, String>{
          'Accept-Api-Version': API_VERSION,
          'X-Username': 'anonymous',
          'X-Password': 'anonymous',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });

    var authId = response.body['authId'];

    /// For some reason this request can sometimes fail with the error;
    ///   code: 401, reason: Unauthorized, message: Session has timed out, detail: {errorCode: 110}
    /// Therefore we retry this request if it fails; a maximum of 10 retries
    /// A real solution should be investigated
    var retries = 10;
    do {
      response = await request(
          endpoint:
              '${settings['EU']['auth_base_url']}json/realms/root/realms/${settings['EU']['realm']}/authenticate',
          additionalHeaders: <String, String>{
            'Accept-Api-Version': API_VERSION,
            'X-Username': 'anonymous',
            'X-Password': 'anonymous',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          params: {
            'authId': authId,
            'template': '',
            'stage': 'LDAP1',
            'header': 'Sign in',
            'callbacks': [
              {
                'type': 'NameCallback',
                'output': [
                  {'name': 'prompt', 'value': 'User Name:'}
                ],
                'input': [
                  {'name': 'IDToken1', 'value': username}
                ]
              },
              {
                'type': 'PasswordCallback',
                'output': [
                  {'name': 'prompt', 'value': 'Password:'}
                ],
                'input': [
                  {'name': 'IDToken2', 'value': password}
                ]
              }
            ]
          });
      _print('Authenticating (retries left: $retries)');
    } while (response.statusCode == 401 && retries-- > 0);

    var authCookie = response.body['tokenId'];

    /// Extremely dirty
    /// The http client throws an error due to an invalid URI from the API
    /// We parse the code used for authentication from the error message
    String code = "";
    try {
      response = await request(
          endpoint:
              '${settings['EU']['auth_base_url']}oauth2${response.body['realm']}/authorize?client_id=${settings['EU']['client_id']}&redirect_uri=${settings['EU']['redirect_uri']}&response_type=code&scope=${settings['EU']['scope']}&nonce=sdfdsfez',
          additionalHeaders: <String, String>{
            'Cookie':
                'i18next=en-UK; amlbcookie=05; kauthSession=\"$authCookie\"'
          },
          method: 'GET');
      print(response.body);
    } on ArgumentError catch (e) {
      code = e.message.split('=')[1].split('&')[0];
    }

    response = await request(
      endpoint:
          '${settings['EU']['auth_base_url']}oauth2${response.body['realm']}/access_token?code=${code}&client_id=${settings['EU']['client_id']}&client_secret=${settings['EU']['client_secret']}&redirect_uri=${settings['EU']['redirect_uri']}&grant_type=authorization_code',
      additionalHeaders: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded'
      },
    );

    this.bearerToken = response.body['access_token'];

    response = await request(
        endpoint: '${settings['EU']['user_adapter_base_url']}v1/users/current',
        method: 'GET');

    var userId = response.body['userId'];

    response = await request(
        endpoint: '${settings['EU']['user_base_url']}v4/users/$userId/cars',
        method: 'GET');

    vehicles = [];

    for (Map vehicle in response.body['data']) {
      vehicles.add(NissanConnectVehicle(
          this,
          Services(vehicle['services'] ?? []),
          vehicle['vin'],
          vehicle['modelName'],
          vehicle['nickname'] ??
              '${vehicle['modelName']} ${vehicles.length + 1}'));
    }

    return vehicle = vehicles.first;
  }

  _print(message) {
    if (debug) {
      print('\$ $message');
      debugLog.add('\$ $message');
    }
  }
}
