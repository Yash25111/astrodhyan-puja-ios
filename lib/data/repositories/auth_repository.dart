import 'package:flutter/foundation.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/http_service.dart';
import '../../core/storage/local_storage.dart';
import '../../utils/device_info.dart';

class AuthRepository {
  final HttpService http;
  final LocalStorage storage;
  AuthRepository({required this.http, required this.storage});
  Future<void> login(String phone) async {
    await http.post(
      ApiEndpoints.login,
      auth: false,
      body: {'number': phone, 'platform': 'app'},
    );
    await storage.setString(LocalStorage.phone, phone);
  }

  Future<void> verify(String phone, String otp) async {
    final r = await http.post(
      ApiEndpoints.verifyOtp,
      auth: false,
      body: {
        'number': phone,
        'otp': otp,
        'deviceToken': await DeviceInfo.deviceToken(),
        'deviceId': await DeviceInfo.deviceId(),
        'platform': 'app',
        'city': '',
        'state': '',
        'referralCode': '',
      },
    );
    if (r is! Map || '${r['token'] ?? ''}'.isEmpty) {
      throw Exception(
        r is Map
            ? '${r['message'] ?? 'OTP verification failed'}'
            : 'Invalid response',
      );
    }
    final token = '${r['token']}';
    if (kDebugMode) {
      debugPrint('Auth token: $token');
    }
    final d = r['data'];
    await storage.setString(LocalStorage.accessToken, token);
    if (d is Map) {
      await storage.setString(LocalStorage.userId, '${d['_id'] ?? ''}');
      await storage.setString(LocalStorage.name, '${d['name'] ?? ''}');
    }
  }

  Future<bool> hasSession() => storage.hasSession();
  Future<void> logout() => storage.clearSession();
}
