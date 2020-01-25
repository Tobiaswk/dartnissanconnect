class NissanConnectHVAC {
  bool isRunning;
  var cabinTemperature;

  NissanConnectHVAC(Map params) {
    var hvac = params['data']['attributes'];
    cabinTemperature = hvac['internalTemperature'];
    isRunning = hvac['hvacStatus'] != 'off';
  }
}
