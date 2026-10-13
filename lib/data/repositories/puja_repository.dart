import '../../core/network/api_endpoints.dart';
import '../../core/network/http_service.dart';
import '../models/puja.dart';
import '../models/puja_detail.dart';

class PujaListPage {
  final List<Puja> items;
  final int page;
  final bool hasMore;

  const PujaListPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });
}

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

  Future<PujaListPage> list({
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
    final items = pujas
        .whereType<Map>()
        .map((e) => Puja.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return PujaListPage(
      items: items,
      page: _currentPage(r, page),
      hasMore: _hasMore(r, page, items.length),
    );
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

  Map<String, dynamic>? _pagination(dynamic response) {
    if (response is! Map) return null;
    final raw =
        response['pagination'] ?? response['meta'] ?? response['pageInfo'];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    final data = response['data'];
    if (data is Map) {
      final nested = data['pagination'] ?? data['meta'] ?? data['pageInfo'];
      if (nested is Map) return Map<String, dynamic>.from(nested);
    }
    return null;
  }

  int _currentPage(dynamic response, int fallback) {
    final pagination = _pagination(response);
    return _intValue(
      pagination?['page'] ?? pagination?['currentPage'],
      fallback,
    );
  }

  bool _hasMore(dynamic response, int requestedPage, int itemCount) {
    final pagination = _pagination(response);
    final currentPage = _intValue(
      pagination?['page'] ?? pagination?['currentPage'],
      requestedPage,
    );
    final totalPages = _intValue(
      pagination?['totalPages'] ?? pagination?['pages'],
      0,
    );
    if (totalPages > 0) return currentPage < totalPages;

    final total = _intValue(
      pagination?['total'] ?? pagination?['totalCount'] ?? pagination?['count'],
      0,
    );
    final limit = _intValue(pagination?['limit'] ?? pagination?['pageSize'], 0);
    if (total > 0 && limit > 0) return currentPage * limit < total;

    return itemCount >= pageSize;
  }

  int _intValue(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
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
