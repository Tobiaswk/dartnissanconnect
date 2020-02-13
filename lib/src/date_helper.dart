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
  var month = _digits(dateTime.month, 2);
  var day = _digits(dateTime.day, 2);
  var hour = _digits(dateTime.hour, 2);
  var minutes = _digits(dateTime.minute, 2);
  var seconds = _digits(dateTime.second, 2);
  Duration timeZoneOffset = dateTime.timeZoneOffset;
  final timeZoneOffsetSb = StringBuffer();
  if (timeZoneOffset.inMinutes == 0) {
    timeZoneOffsetSb.write('Z');
  } else {
    if (timeZoneOffset.isNegative) {
      timeZoneOffsetSb.write('-');
      timeZoneOffsetSb.write(_digits((-timeZoneOffset.inHours) % 24, 2));
      timeZoneOffsetSb.write(':');
      timeZoneOffsetSb.write(_digits((-timeZoneOffset.inMinutes) % 60, 2));
    } else {
      timeZoneOffsetSb.write('+');
      timeZoneOffsetSb.write(_digits(timeZoneOffset.inHours % 24, 2));
      timeZoneOffsetSb.write(':');
      timeZoneOffsetSb.write(_digits(timeZoneOffset.inMinutes % 60, 2));
    }
  }

  var timeZone = timeZoneOffsetSb.toString();
  return "$year-$month-${day}T$hour:$minutes:${seconds}$timeZone";
}
