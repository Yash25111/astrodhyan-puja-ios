import '../../core/network/api_endpoints.dart';
import '../../core/network/http_service.dart';
import '../../core/storage/local_storage.dart';
import '../models/user_profile.dart';
class ProfileRepository {
  final HttpService http;
  final LocalStorage storage;
  ProfileRepository({
    required this.http,required this.storage
  }
  );
  Future<UserProfile> get() async {
    final r=await http.get(ApiEndpoints.profile);
    if(r is! Map||r['data'] is! Map)throw Exception('Invalid profile response');
    final p=UserProfile.fromJson(Map<String,dynamic>.from(r['data']));
    await _save(p);
    return p;
  }
  Future<UserProfile> update({
    required String name,required String email,required String gender,String? imagePath
  }
  ) async {
    final r=await http.putMultipart(ApiEndpoints.updateProfile,fields:{
      'name':name,'email':email,'gender':gender
    }
    ,filePath:imagePath);
    if(r is! Map||r['data'] is! Map)throw Exception('Invalid update response');
    final p=UserProfile.fromJson(Map<String,dynamic>.from(r['data']));
    await _save(p);
    return p;
  }
  Future<void> _save(UserProfile p) async {
    await storage.setString(LocalStorage.userId,p.id);
    await storage.setString(LocalStorage.name,p.name);
    await storage.setString(LocalStorage.phone,p.number);
    await storage.setString(LocalStorage.profileImage,p.image);
    await storage.setNum(LocalStorage.wallet,p.wallet);
  }
}
