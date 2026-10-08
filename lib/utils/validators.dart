class Validators {
  Validators._();
  static String? phone(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(s)) return 'Enter a valid 10-digit phone number';
    return null;
  }
  static String? required(String? v, String field) => (v?.trim().isEmpty ?? true) ? '$field is required' : null;
  static String? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Email is required';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s) ? null : 'Enter a valid email';
  }
}
