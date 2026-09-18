class MyNissanRegionSettings {
  const MyNissanRegionSettings({
    required this.client,
    required this.clientId,
    required this.clientSecret,
    required this.scope,
    required this.authBaseUrl,
    required this.realm,
    required this.redirectUri,
    required this.carAdapterBaseUrl,
    required this.userAdapterBaseUrl,
    required this.userBaseUrl,
  });

  final String client;
  final String clientId;
  final String clientSecret;
  final String scope;
  final String authBaseUrl;
  final String realm;
  final String redirectUri;
  final String carAdapterBaseUrl;
  final String userAdapterBaseUrl;
  final String userBaseUrl;
}

enum MyNissanRegion {
  eu('EU');

  const MyNissanRegion(this.code);

  final String code;

  MyNissanRegionSettings get settings => MyNissanSettings.of(this);

  static MyNissanRegion fromCode(String code) =>
      MyNissanRegion.values.firstWhere(
        (MyNissanRegion region) =>
            region.code.toUpperCase() == code.toUpperCase(),
        orElse: () =>
            throw ArgumentError.value(code, 'code', 'Unknown Nissan region'),
      );
}

abstract final class MyNissanSettings {
  static const MyNissanRegionSettings eu = MyNissanRegionSettings(
    client: 'mynissanapp',
    clientId: 'ZM3WK7ax1OtQKYQ8Qqzcv5VgiA8a',
    clientSecret:
        '6GKIax7fGT5yPHuNmWNVOc4q5POBw1WRSW39ubRA8WPBmQ7MOxhm75EsmKMKENem',
    scope: 'openid name profile email offline_access',
    authBaseUrl: 'https://login.mynissan-account.com',
    realm: 'a-ncb-prod',
    redirectUri: 'com://wso2.service.nci',
    // carAdapter_eu_prod
    carAdapterBaseUrl:
        'https://alliance-platform-caradapter-prod.apps.eu2.kamereon.io/car-adapter/',
    // userAdapter_eu_prod
    userAdapterBaseUrl:
        'https://alliance-platform-usersadapter-prod.apps.eu2.kamereon.io/user-adapter/',
    // bffWeb_eu_prod
    userBaseUrl: 'https://nci-bff-web-prod.apps.eu2.kamereon.io/bff-web/',
  );

  static const Map<MyNissanRegion, MyNissanRegionSettings> byRegion =
      <MyNissanRegion, MyNissanRegionSettings>{MyNissanRegion.eu: eu};

  static MyNissanRegionSettings of(MyNissanRegion region) =>
      byRegion[region] ??
      (throw ArgumentError.value(
        region,
        'region',
        'No settings configured for region',
      ));

  static MyNissanRegionSettings byCode(String code) =>
      of(MyNissanRegion.fromCode(code));
}
