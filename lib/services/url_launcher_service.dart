import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  UrlLauncherService._();

  static Future<bool> openUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasAuthority ||
        !['http', 'https'].contains(uri.scheme)) {
      return false;
    }

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }
}
