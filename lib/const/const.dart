import 'package:intl/intl.dart';

class Const {
  static const String accessToken = "accessToken";
  static const String userId = "userId";
  static const String loginStatus = "login_status";
  static const String appVersion = "0.1";
}

String getDataAndTime(date) {
  String isoDate = date;
  DateTime dateTime = DateTime.parse(isoDate);
  DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
  String formattedDate = dateFormat.format(dateTime);
  return formattedDate;
}
