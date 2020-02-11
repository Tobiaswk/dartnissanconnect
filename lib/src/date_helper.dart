import 'package:intl/intl.dart';

String _digits(int value, int length) {
  String ret = '$value';
  if (ret.length < length) {
    ret = '0' * (length - ret.length) + ret;
  }
  return ret;
}

String formatDateWithTimeZone(DateTime dateTime) {
  var year = dateTime.year;
  var month = NumberFormat('00').format(dateTime.month);
  var day = NumberFormat('00').format(dateTime.day);
  var hour = NumberFormat('00').format(dateTime.hour);
  var minutes = NumberFormat('00').format(dateTime.minute);
  var seconds = NumberFormat('00').format(dateTime.second);
  Duration timeZoneOffset = dateTime.timeZoneOffset;
  final timeZoneOffsetsb = StringBuffer();
  if (timeZoneOffset.inMinutes == 0) {
    timeZoneOffsetsb.write('Z');
  } else {
    if (timeZoneOffset.isNegative) {
      timeZoneOffsetsb.write('-');
      timeZoneOffsetsb.write(_digits((-timeZoneOffset.inHours) % 24, 2));
      timeZoneOffsetsb.write(':');
      timeZoneOffsetsb.write(_digits((-timeZoneOffset.inMinutes) % 60, 2));
    } else {
      timeZoneOffsetsb.write('+');
      timeZoneOffsetsb.write(_digits(timeZoneOffset.inHours % 24, 2));
      timeZoneOffsetsb.write(':');
      timeZoneOffsetsb.write(_digits(timeZoneOffset.inMinutes % 60, 2));
    }
    var timezone = timeZoneOffsetsb.toString();

    return "$year-$month-${day}T$hour:$minutes:${seconds}$timezone";
  }
}

