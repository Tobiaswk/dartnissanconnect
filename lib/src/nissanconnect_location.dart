class NissanConnectLocation {
  var latitude;
  var longitude;

  NissanConnectLocation(Map map) {
    this.latitude = map['sandsNotificationEvent']['sandsNotificationEvent']
        ['body']['location']['latitudeDMS'];
    this.longitude = map['sandsNotificationEvent']['sandsNotificationEvent']
        ['body']['location']['longitudeDMS'];
  }
}
