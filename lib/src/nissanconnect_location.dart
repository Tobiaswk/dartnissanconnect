class NissanConnectLocation {
  var latitude;
  var longitude;

  NissanConnectLocation(Map map) {
    this.latitude = map['gpsLatitude'];
    this.longitude = map['gpsLongitude'];
  }
}
