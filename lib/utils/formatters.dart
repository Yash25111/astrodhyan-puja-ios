import 'package:intl/intl.dart';
class Formatters {
  Formatters._();
  static String date(String value) {
    final d = DateTime.tryParse(value);
    return d == null ? value : DateFormat('dd MMM yyyy').format(d.toLocal());
  }
  static String amount(num value) => NumberFormat('#,##0.##').format(value);
}
