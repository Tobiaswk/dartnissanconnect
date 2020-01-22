import 'package:date_format/date_format.dart';

// There is little to no timezone support with dates for dart
// Therefore we use the date_format package here
// it outputs timezone as '+0100' etc. we need '+01:10'
// date_format does not support this so we do this here in a hacky way
String formatDateWithTimeZone(DateTime dateTime) {
  var datePart1 = formatDate(
          dateTime, [yyyy, '-', mm, '-', dd, 'T', HH, ':', nn, ':', ss, z])
      .substring(0, 22);
  var datePart2 = formatDate(
          dateTime, [yyyy, '-', mm, '-', dd, 'T', HH, ':', nn, ':', ss, z])
      .substring(22, 24);
  return "$datePart1:$datePart2";
}
