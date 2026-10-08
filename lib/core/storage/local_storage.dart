import 'package:shared_preferences/shared_preferences.dart';
class LocalStorage {
  static const accessToken = 'access_token';
  static const userId = '_id';
  static const phone = 'user_phone_number';
  static const name = 'user_name';
  static const profileImage = 'profile_image';
  static const wallet = 'user_wallet';
  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();
  Future<void> setString(String key, String value) async => (await _p).setString(key, value);
  Future<String?> getString(String key) async => (await _p).getString(key);
  Future<void> setNum(String key, num value) async => setString(key, value.toString());
  Future<bool> hasSession() async => (await getString(accessToken))?.isNotEmpty == true;
  Future<void> clearSession() async {
    final p = await _p;
    for (final key in [accessToken, userId, phone, name, profileImage, wallet]) {
      await p.remove(key);
    }
  }
}
