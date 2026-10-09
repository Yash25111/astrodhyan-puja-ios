import '../../core/network/api_endpoints.dart';
import '../../core/network/http_service.dart';
import '../models/puja.dart';
import '../models/puja_detail.dart';

class PujaRepository {
  static const pageSize = 10;

  final HttpService http;

  PujaRepository({required this.http});

  Future<PujaHomeData> home({
    int page = 1,
    int limit = pageSize,
    String lang = 'en',
    String search = '',
  }) async {
    final r = await http.get(
      ApiEndpoints.pujaHome,
      query: {
        'page': page,
        'limit': limit,
        'lang': lang,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
      language: lang,
    );
    if (r is! Map) throw Exception('Invalid puja home response');
    return PujaHomeData.fromJson(Map<String, dynamic>.from(r));
  }

  Future<List<Puja>> list({
    int page = 1,
    String lang = 'en',
    String search = '',
  }) async {
    final trimmedSearch = search.trim();
    final r = await http.get(
      ApiEndpoints.puja,
      query: {
        'page': page,
        'lang': lang,
        if (trimmedSearch.length >= 3) 'search': trimmedSearch,
      },
      language: lang,
    );
    final pujas = _extractPujaList(r);
    return pujas
        .whereType<Map>()
        .map((e) => Puja.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List<dynamic> _extractPujaList(dynamic response) {
    if (response is List) return response;
    if (response is! Map) throw Exception('Invalid puja list response');

    final data = response['data'];
    if (data is List) return data;
    if (data is Map) {
      return _firstList(data, const [
        'pujas',
        'poojas',
        'pujaList',
        'poojaList',
        'docs',
        'results',
        'items',
        'data',
      ]);
    }

    return _firstList(response, const [
      'pujas',
      'poojas',
      'pujaList',
      'poojaList',
      'docs',
      'results',
      'items',
    ]);
  }

  List<dynamic> _firstList(Map<dynamic, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is List) return value;
    }
    throw Exception('Puja list not found in response');
  }

  Future<PujaDetail> detail(String id, {String lang = 'en'}) async {
    final r = await http.get(
      '${ApiEndpoints.puja}$id',
      query: {'lang': lang},
      language: lang,
    );
    if (r is! Map) throw Exception('Invalid puja response');
    final d = r['data'];
    if (d is Map && d['puja'] is Map) {
      final reviews = (d['latestReviews'] as List? ?? [])
          .whereType<Map>()
          .map((e) => PujaReview.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return PujaDetail.fromJson(
        Map<String, dynamic>.from(d['puja'] as Map),
        reviews: reviews,
      );
    }
    if (d is Map) return PujaDetail.fromJson(Map<String, dynamic>.from(d));
    throw Exception('Puja not found');
  }
}
