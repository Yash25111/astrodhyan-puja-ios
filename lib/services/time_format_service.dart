import 'package:intl/intl.dart';

class TimeFormatService {
  TimeFormatService._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static String formatDate(String? value, {String fallback = ''}) {
    final raw = _clean(value);
    if (raw == null) return fallback;
    final parsed = _parseDate(raw);
    return parsed == null ? raw : _dateFormat.format(parsed.toLocal());
  }

  static String formatTime(String? value, {String fallback = ''}) {
    final raw = _clean(value);
    if (raw == null) return fallback;

    final dateTime = _parseDate(raw);
    if (dateTime != null && _hasTimeValue(raw)) {
      return _timeFormat.format(dateTime.toLocal());
    }

    final timeOnly = _parseTime(raw);
    return timeOnly == null ? raw : _timeFormat.format(timeOnly);
  }

  static String formatDateTime(String? value, {String fallback = ''}) {
    final raw = _clean(value);
    if (raw == null) return fallback;
    final parsed = _parseDate(raw);
    return parsed == null ? raw : _dateTimeFormat.format(parsed.toLocal());
  }

  static String? _clean(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') {
      return null;
    }
    return raw;
  }

  static DateTime? _parseDate(String value) {
    return DateTime.tryParse(value);
  }

  static DateTime? _parseTime(String value) {
    final normalized = value
        .replaceFirst(RegExp(r'\.\d+Z?$'), '')
        .replaceFirst(RegExp(r'Z$'), '')
        .trim()
        .toUpperCase();
    for (final pattern in const [
      'HH:mm:ss',
      'HH:mm',
      'hh:mm:ss a',
      'h:mm:ss a',
      'hh:mm a',
      'h:mm a',
    ]) {
      try {
        return DateFormat(pattern).parseStrict(normalized);
      } catch (_) {
        // Try the next supported server time shape.
      }
    }
    return null;
  }

  static bool _hasTimeValue(String value) {
    return value.contains('T') || RegExp(r'\d{1,2}:\d{2}').hasMatch(value);
  }
}
