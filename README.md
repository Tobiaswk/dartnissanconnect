# dartnissanconnect

A Dart client library for the NissanConnect API for vehicles produced after May 2019.

Through the NissanConnect API you can ask your vehicle for the latest data, see current battery and charging statuses, see the current climate control state, start or stop climate control remotely, remotely start charging, and retrieve the last known location of the vehicle.

## Usage

A simple usage example:

    import 'package:dartnissanconnect/dartnissanconnect.dart';

    main() {
      NissanConnectSession session = new NissanConnectSession(debug: true);

      session.login(username: "username", password: "password").then((vehicle) {
        print(vehicle.vin);
        print(vehicle.modelYear);
        print(vehicle.nickname);
      });
    }
