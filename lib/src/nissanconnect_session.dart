import 'package:dartnissanconnect/src/nissanconnect_response.dart';
import 'package:dartnissanconnect/src/nissanconnect_vehicle.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NissanConnectSession {
  Map settings = <String, Map>{
    "EU": <String, String>{
      "client_id": "a-ncb-prod-android",
      "client_secret":
          "3LBs0yOx2XO-3m4mMRW27rKeJzskhfWF0A8KUtnim8i/qYQPl8ZItp3IaqJXaYj_",
      "scope": "openid profile vehicles",
      "auth_base_url": "https://prod.eu.auth.kamereon.org/kauth/",
      "realm": "a-ncb-prod",
      "redirect_uri": "org.kamereon.service.nci:/oauth2redirect",
      "car_adapter_base_url":
          "https://alliance-platform-caradapter-prod.apps.eu.kamereon.io/car-adapter/",
      "user_adapter_base_url":
          "https://alliance-platform-usersadapter-prod.apps.eu.kamereon.io/user-adapter/",
      "user_base_url": "https://nci-bff-web-prod.apps.eu.kamereon.io/bff-web/"
    }
  };

  var API_VERSION = "protocol=1.0,resource=2.1";
  var SRP_KEY =
      "D5AF0E14718E662D12DBB4FE42304DF5A8E48359E22261138B40AA16CC85C76A11B43200A1EECB3C9546A262D1FBD51ACE6FCDE558C00665BBF93FF86B9F8F76AA7A53CA74F5B4DFF9A4B847295E7D82450A2078B5A28814A7A07F8BBDD34F8EEB42B0E70499087A242AA2C5BA9513C8F9D35A81B33A121EEF0A71F3F9071CCD";

  bool debug;
  List<String> debugLog = List<String>();

  var username;
  var password;
  var bearerToken;

  NissanConnectVehicle vehicle;
  List<NissanConnectVehicle> vehicles;

  NissanConnectSession({this.debug = false});

  Future<NissanConnectResponse> requestWithRetry(
      {String endpoint,
      String method = "POST",
      Map additionalHeaders,
      Map params}) async {
    NissanConnectResponse response = await request(
        endpoint: endpoint,
        method: method,
        additionalHeaders: additionalHeaders,
        params: params);

    var status = response.statusCode;

    if (status != null && status >= 400) {
      _print(
          'NissanConnect API; logging in and trying request again: $response');

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
      {String endpoint,
      String method = "POST",
      Map additionalHeaders,
      Map params}) async {
    _print('Invoking NissanConnect API: $endpoint');
    _print('Params: $params');

    Map<String, String> headers = Map();

    if (bearerToken != null) {
      headers["Authorization"] = "Bearer $bearerToken";
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    _print('Headers: $headers');

    http.Response response;
    switch (method) {
      case "GET":
        response = await http.get("${endpoint}", headers: headers);
        break;
      default:
        response = await http.post("${endpoint}",
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

  Future<NissanConnectVehicle> login({String username, String password}) async {
    this.username = username;
    this.password = password;
    this.bearerToken = null;

    NissanConnectResponse response = await request(
        endpoint:
            "${settings["EU"]["auth_base_url"]}json/realms/root/realms/${settings["EU"]["realm"]}/authenticate",
        additionalHeaders: <String, String>{
          "Accept-Api-Version": API_VERSION,
          "X-Username": "anonymous",
          "X-Password": "anonymous",
          "Content-Type": "application/json",
          "Accept": "application/json"
        });

    var authId = response.body["authId"];

    response = await request(
        endpoint:
            "${settings["EU"]["auth_base_url"]}json/realms/root/realms/${settings["EU"]["realm"]}/authenticate",
        additionalHeaders: <String, String>{
          "Accept-Api-Version": API_VERSION,
          "X-Username": "anonymous",
          "X-Password": "anonymous",
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        params: {
          "authId": authId,
          "template": "",
          "stage": "LDAP1",
          "header": "Sign in",
          "callbacks": [
            {
              "type": "NameCallback",
              "output": [
                {"name": "prompt", "value": "User Name:"}
              ],
              "input": [
                {"name": "IDToken1", "value": username}
              ]
            },
            {
              "type": "PasswordCallback",
              "output": [
                {"name": "prompt", "value": "Password:"}
              ],
              "input": [
                {"name": "IDToken2", "value": password}
              ]
            }
          ]
        });

    var authCookie = response.body['tokenId'];

    // Extremely dirty
    // The http client throws an error due to an invalid URI from the API
    // We parse the code used for authentication from the error message
    String code;
    try {
      response = await request(
          endpoint:
              "${settings["EU"]["auth_base_url"]}oauth2${response.body["realm"]}/authorize?client_id=${settings["EU"]["client_id"]}&redirect_uri=${settings["EU"]["redirect_uri"]}&response_type=code&scope=${settings["EU"]["scope"]}&nonce=sdfdsfez",
          additionalHeaders: <String, String>{
            "Cookie":
                "i18next=en-UK; amlbcookie=05; kauthSession=\"$authCookie\""
          },
          method: 'GET');
      print(response.body);
    } catch (e) {
      code = e.message.split("=")[1].split('&')[0];
    }

    response = await request(
      endpoint:
          "${settings["EU"]["auth_base_url"]}oauth2${response.body["realm"]}/access_token?code=$code&client_id=${settings["EU"]["client_id"]}&client_secret=${settings["EU"]["client_secret"]}&redirect_uri=${settings["EU"]["redirect_uri"]}&grant_type=authorization_code",
      additionalHeaders: <String, String>{
        "Content-Type": "application/x-www-form-urlencoded"
      },
    );

    this.bearerToken = response.body['access_token'];

    response = await request(
        endpoint: "${settings["EU"]["user_adapter_base_url"]}v1/users/current",
        method: 'GET');

    var userId = response.body['userId'];

    response = await request(
        endpoint: "${settings["EU"]["user_base_url"]}v2/users/$userId/cars",
        method: 'GET');

    vehicles = List<NissanConnectVehicle>();

    for (Map vehicle in response.body["data"]) {
      vehicles.add(new NissanConnectVehicle(this, vehicle["vin"],
          vehicle["modelName"], vehicle["nickname"] ?? vehicle["modelName"]));
    }

    return vehicle = vehicles.first;
  }

  _print(message) {
    if (debug) {
      print(message);
      debugLog.add(message);
    }
  }
}
