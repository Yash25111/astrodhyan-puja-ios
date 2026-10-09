import 'package:intl/intl.dart';

import '../services/time_format_service.dart';

class Formatters {
  Formatters._();
  static String date(String value) => TimeFormatService.formatDate(value);

  static String time(String value) => TimeFormatService.formatTime(value);

  static String dateTime(String value) =>
      TimeFormatService.formatDateTime(value);

  static String amount(num value) => NumberFormat('#,##0.##').format(value);
}
