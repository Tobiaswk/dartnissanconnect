import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:dartnissanconnect/src/date_helper.dart';

main() {
  NissanConnectSession session = new NissanConnectSession(debug: true);

  // UK Test
  // PHowarth@BlueYonder.co.uk
  // W3stergaard!

  // German test
  // mondi@mhv-ms.de
  // KoraDeti148-1949
  session
      .login(username: "PHowarth@BlueYonder.co.uk", password: "W3stergaard!")
      .then((vehicle) {
    print(vehicle.nickname);
    print(vehicle.modelName);
    print(vehicle.vin);
/*    vehicle.requestDailyStatistics().then((stats) {
      print(stats.travelSpeedAverageKmh);
      print(stats.travelSpeedAverageMph);
    });*/
/*    vehicle.requestMonthlyStatistics(month: DateTime.now()).then((stats) {
      print(stats.travelSpeedAverageKmh);
      print(stats.travelSpeedAverageMph);
    });*/
/*    vehicle.requestBatteryStatus().then((stats) {
       print(stats.isCharging);
       print(stats.isConnected);
       print(stats.batteryPercentage);
       print(stats.cruisingRangeAcOffKm);
       print(stats.cruisingRangeAcOnKm);
       print(stats.cruisingRangeAcOffMiles);
       print(stats.cruisingRangeAcOnMiles);
       print(stats.chargingkWLevelText);
       print(stats.chargingRemainingText);
    });*/
    /*
      vehicle.requestMonthlyStatistics(month: DateTime(DateTime.now().year, DateTime.may)).then((data) {
        print(data.date);
        print(data.kWhUsed);
        print(data.kWhGained);
      });*/
    /*vehicle.requestClimateControlOn(DateTime.now(), 21);*/
/*    vehicle.requestMonthlyTripsStatistics(DateTime.now()).then((data) {
      for (NissanConnectStats stat in data) {
        print(stat.date);
        print(stat.travelDistanceKilometers);
        print(stat.kWhGained);
        print(stat.kWhUsed);
      }
    });*/
/*    vehicle.requestMonthlyStatistics(month: DateTime(2020,6)).then((data) {
      print(data.date);
      print(data.travelDistanceKilometers);
      print(data.kWhGained);
      print(data.kWhUsed);
    });*/
  });
  print(formatDateWithTimeZone(DateTime.now()));
}

