import 'package:dartnissanconnect/src/nissanconnect_response.dart';
import 'package:dartnissanconnect/src/nissanconnect_vehicle.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NissanConnectSession {
  bool debug;
  List<String> debugLog = List<String>();

  var username;
  var password;
  var bearerToken;

  NissanConnectVehicle vehicle;
  List<NissanConnectVehicle> vehicles;

  NissanConnectSession({this.debug = false});

  Future<NissanConnectResponse> requestWithRetry(
      {String endpoint, String method = "POST", Map additionalHeaders, Map params}) async {
    NissanConnectResponse response =
        await request(endpoint: endpoint, method: method, additionalHeaders: additionalHeaders, params: params);

    var status = response.statusCode;

    if (status != null && status >= 400) {
      _print(
          'NissanConnect API; logging in and trying request again: $response');

      await login(username: username, password: password);

      response =
          await request(endpoint: endpoint, method: method, params: params);
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
      _print('result: $jsonData');
    } catch (e) {
      _print('JSON decoding failed!');
    }

    return NissanConnectResponse(
        response.statusCode, response.headers, jsonData);
  }

  Future<NissanConnectVehicle> login({String username, String password}) async {
    this.username = username;
    this.password = password;

    Map<String, String> headers = Map();
    headers["Accept-Api-Version"] = 'protocol=1.0,resource=2.1';
    headers["Host"] = "prod.eu.auth.kamereon.org";
    headers["Accept-Api-Version"] = "protocol=1.0,resource=2.1";
    headers["Origin"] = "https://prod.eu.auth.kamereon.org";
    headers["X-Password"] = "anonymous";
    headers["Accept-Language"] = "en-UK";
    headers["X-Username"] = "anonymous";
    headers["User-Agent"] =
        "Mozilla/5.0 (Linux; Android 5.1.1; SM-N950N Build/NMF26X; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/74.0.3729.136 Mobile Safari/537.36";
    headers["Content-Type"] = "application/json";
    headers["Accept"] = "application/json, text/javascript, */*; q=0.01";
    headers["Cache-Control"] = "no-cache";
    headers["X-Requested-With"] = "XMLHttpRequest";
    headers["X-Nosession"] = "true";
    headers["Referer"] =
        "https://prod.eu.auth.kamereon.org/kauth/XUI/?realm=%2Fa-ncb-prod&goto=https%3A%2F%2Fprod.eu.auth.kamereon.org%2Fkauth%2Foauth2%2Fa-ncb-prod%2Fauthorize%3Fclient_id%3Da-ncb-prod-android%26redirect_uri%3Dorg.kamereon.service.nci%253A%252Foauth2redirect%26response_type%3Dcode%26scope%3Dopenid%2520profile%2520vehicles%26state%3Daf0ifjsldkj%26nonce%3Dsdfdsfez";
    headers["Cookie"] = "i18next=en-UK";

    NissanConnectResponse response = await request(
        endpoint:
            "https://prod.eu.auth.kamereon.org/kauth/json/realms/root/realms/a-ncb-prod/authenticate?goto=https%3A%2F%2Fprod.eu.auth.kamereon.org%2Fkauth%2Foauth2%2Fa-ncb-prod%2Fauthorize%3Fclient_id%3Da-ncb-prod-android%26redirect_uri%3Dorg.kamereon.service.nci%253A%252Foauth2redirect%26response_type%3Dcode%26scope%3Dopenid%2520profile%2520vehicles%26state%3Daf0ifjsldkj%26nonce%3Dsdfdsfez",
        additionalHeaders: headers);

    var authId = response.body["authId"];

    headers['Cookie'] = response.headers['set-cookie'];

    response = await request(
        endpoint:
            "https://prod.eu.auth.kamereon.org/kauth/json/realms/root/realms/a-ncb-prod/authenticate?goto=https%3A%2F%2Fprod.eu.auth.kamereon.org%2Fkauth%2Foauth2%2Fa-ncb-prod%2Fauthorize%3Fclient_id%3Da-ncb-prod-android%26redirect_uri%3Dorg.kamereon.service.nci%253A%252Foauth2redirect%26response_type%3Dcode%26scope%3Dopenid%2520profile%2520vehicles%26state%3Daf0ifjsldkj%26nonce%3Dsdfdsfez",
        additionalHeaders: headers,
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

    //String authCookie = response.headers['set-cookie'];
    //authCookie = authCookie.replaceAll('kauthSession="', '').replaceAll('"; Path=/; Secure; HttpOnly', '').trim();
    String authCookie = response.body['tokenId'];
    headers = Map<String, String>();
    headers["Host"] = "prod.eu.auth.kamereon.org";
    headers["Upgrade-Insecure-Requests"] = "1";
    headers["User-Agent"] =
        "Mozilla/5.0 (Linux; Android 5.1.1; SM-N950N Build/NMF26X; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/74.0.3729.136 Mobile Safari/537.36";
    headers["Accept"] =
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3";
    headers["Referer"] =
        "https://prod.eu.auth.kamereon.org/kauth/XUI/?realm=%2Fa-ncb-prod&goto=https%3A%2F%2Fprod.eu.auth.kamereon.org%2Fkauth%2Foauth2%2Fa-ncb-prod%2Fauthorize%3Fclient_id%3Da-ncb-prod-android%26redirect_uri%3Dorg.kamereon.service.nci%253A%252Foauth2redirect%26response_type%3Dcode%26scope%3Dopenid%2520profile%2520vehicles%26state%3Daf0ifjsldkj%26nonce%3Dsdfdsfez";
    headers["Accept-Language"] = "en-UK,en-US;q=0.9,en;q=0.8";
    headers["Cookie"] =
        "i18next=en-UK; amlbcookie=05; kauthSession=\"$authCookie\"";
    headers["X-Requested-With"] = "com.android.browser";

    // Extremely dirty
    // The http client throws an error due to an invalid URI from the API
    // We parse the code used for authentication from the error message
    String code;
    try {
      response = await request(
          endpoint:
              "https://prod.eu.auth.kamereon.org/kauth/oauth2/a-ncb-prod/authorize?client_id=a-ncb-prod-android&redirect_uri=org.kamereon.service.nci%3A%2Foauth2redirect&response_type=code&scope=openid%20profile%20vehicles&state=af0ifjsldkj&nonce=sdfdsfez",
          additionalHeaders: headers,
          method: 'GET');
    } catch (e) {
      code = e.message.split("=")[1].split('&')[0];
    }

    headers = Map<String, String>();
    headers["Host"] = 'prod.eu.auth.kamereon.org';
    headers["User-Agent"] = 'okhttp/3.11.0';
    headers["Content-Type"] = 'application/x-www-form-urlencoded';

    response = await request(
      endpoint:
          "https://prod.eu.auth.kamereon.org/kauth/oauth2/a-ncb-prod/access_token?code=$code&client_id=a-ncb-prod-android&client_secret=3LBs0yOx2XO-3m4mMRW27rKeJzskhfWF0A8KUtnim8i%2FqYQPl8ZItp3IaqJXaYj_&redirect_uri=org.kamereon.service.nci%3A%2Foauth2redirect&grant_type=authorization_code",
      additionalHeaders: headers,
    );

    this.bearerToken = response.body['access_token'];

    response = await request(
        endpoint:
            "https://alliance-platform-usersadapter-prod.apps.eu.kamereon.io/user-adapter/v1/users/current",
        method: 'GET');

    var userId = response.body['userId'];

    response = await request(
        endpoint:
            "https://nci-bff-web-prod.apps.eu.kamereon.io/bff-web/v2/users/$userId/cars",
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
