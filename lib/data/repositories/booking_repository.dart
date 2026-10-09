import '../../core/network/api_endpoints.dart';
import '../../core/network/http_service.dart';
import '../models/order_result.dart';
import '../models/transaction.dart';

class BookingRepository {
  static const pageSize = 10;

  final HttpService http;

  BookingRepository({required this.http});

  Future<OrderResult> createOrder({
    required String pujaId,
    required String packageId,
    required List<String> offerings,
    required List<MemberDetails> members,
    String? astrologerId,
  }) async {
    final r = await http.post(
      ApiEndpoints.createPujaOrder,
      body: {
        'pujaId': pujaId,
        'packageId': packageId,
        'selectedOfferings': offerings,
        'customerDetails': members
            .map(
              (m) => {
                'fullName': m.fullName,
                'gender': m.gender,
                'gotram': m.gotram,
              },
            )
            .toList(),
        if (astrologerId != null && astrologerId.isNotEmpty)
          'astrologerId': astrologerId,
      },
    );
    if (r is! Map) throw Exception('Invalid order response');
    return OrderResult.fromJson(Map<String, dynamic>.from(r));
  }

  Future<List<PujaTransaction>> history({
    int page = 1,
    int limit = pageSize,
  }) async {
    final r = await http.get(
      ApiEndpoints.transactions,
      query: {'page': page, 'limit': limit},
    );
    final d = r is Map ? r['transactions'] : null;
    return d is List
        ? d
              .whereType<Map>()
              .map(
                (e) => PujaTransaction.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : [];
  }

  Future<TransactionDetail> transaction(String id) async {
    final r = await http.get('${ApiEndpoints.transactionDetails}/$id');
    if (r is! Map || r['transaction'] is! Map) {
      throw Exception('Invalid transaction response');
    }
    return TransactionDetail.fromJson(
      Map<String, dynamic>.from(r['transaction'] as Map),
    );
  }

  Future<void> review({
    required String pujaId,
    required String transactionId,
    required String text,
    required double rating,
  }) async {
    await http.post(
      ApiEndpoints.submitReview,
      body: {
        'pujaId': pujaId,
        'transactionId': transactionId,
        'review': text,
        'rating': rating,
      },
    );
  }
}
