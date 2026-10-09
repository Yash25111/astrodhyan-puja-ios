class MemberDetails {
  final String fullName;
  final String gender;
  final String gotram;

  const MemberDetails({
    required this.fullName,
    required this.gender,
    required this.gotram,
  });

  factory MemberDetails.fromJson(Map<String, dynamic> j) => MemberDetails(
    fullName: _s(j['fullName'] ?? j['name']),
    gender: _s(j['gender']),
    gotram: _s(j['gotram']),
  );
}

class TransactionOffering {
  final String id;
  final String title;
  final String description;
  final num price;

  const TransactionOffering({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  factory TransactionOffering.fromJson(Map<String, dynamic> j) =>
      TransactionOffering(
        id: _s(j['_id'] ?? j['id']),
        title: _s(j['header'] ?? j['title'] ?? j['name']),
        description: _s(j['description']),
        price: _n(j['price']),
      );
}

class PujaTransaction {
  final String id;
  final String name;
  final String date;
  final String status;
  final String paymentStatus;
  final String image;
  final String pujaId;
  final String createdAt;
  final String videoUrl;
  final double rating;

  const PujaTransaction({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    required this.paymentStatus,
    required this.image,
    required this.pujaId,
    required this.createdAt,
    required this.videoUrl,
    required this.rating,
  });

  factory PujaTransaction.fromJson(Map<String, dynamic> j) {
    final p = j['pujaId'];
    final puja = p is Map ? Map<String, dynamic>.from(p) : null;
    final pujaStatus = _s(j['pujaStatus']);
    final paymentStatus = _s(j['status']);
    return PujaTransaction(
      id: _s(j['_id']),
      name: _s(j['pujaName'] ?? puja?['title']),
      date: _s(j['pujaDate']),
      status: pujaStatus.isNotEmpty ? pujaStatus : paymentStatus,
      paymentStatus: paymentStatus,
      image: _s(puja?['pujaImage']),
      pujaId: _s(puja?['_id'] ?? p),
      createdAt: _s(j['created_at'] ?? j['createdAt']),
      videoUrl: _s(j['videoUrl']),
      rating: _d(j['rating']),
    );
  }
}

class TransactionDetail {
  final String id;
  final String userId;
  final String name;
  final String date;
  final String time;
  final String location;
  final String status;
  final String pujaStatus;
  final String paymentStatus;
  final String orderId;
  final String paymentId;
  final String receiptId;
  final String couponCode;
  final String initiatedAt;
  final String completedAt;
  final String createdAt;
  final String updatedAt;
  final String image;
  final String packageType;
  final String pujaId;
  final String videoUrl;
  final num total;
  final num orderAmount;
  final num discount;
  final num packagePrice;
  final double rating;
  final bool isPaymentAttempted;
  final List<MemberDetails> members;
  final List<TransactionOffering> offerings;

  const TransactionDetail({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    required this.pujaStatus,
    required this.paymentStatus,
    required this.orderId,
    required this.paymentId,
    required this.receiptId,
    required this.couponCode,
    required this.initiatedAt,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.image,
    required this.packageType,
    required this.pujaId,
    required this.videoUrl,
    required this.total,
    required this.orderAmount,
    required this.discount,
    required this.packagePrice,
    required this.rating,
    required this.isPaymentAttempted,
    required this.members,
    required this.offerings,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> j) {
    final p = j['pujaId'] is Map ? Map<String, dynamic>.from(j['pujaId']) : {};
    final pkg = j['package'] is Map
        ? Map<String, dynamic>.from(j['package'])
        : {};
    final pujaStatus = _s(j['pujaStatus']);
    final paymentStatus = _s(j['status']);
    return TransactionDetail(
      id: _s(j['_id']),
      userId: _s(j['userId']),
      name: _s(j['pujaName'] ?? p['title']),
      date: _s(j['pujaDate']),
      time: _s(j['pujaTime']),
      location: _s(j['location']),
      status: pujaStatus.isNotEmpty ? pujaStatus : paymentStatus,
      pujaStatus: pujaStatus,
      paymentStatus: paymentStatus,
      orderId: _s(j['orderId']),
      paymentId: _s(j['paymentId']),
      receiptId: _s(j['receiptId']),
      couponCode: _s(j['couponCode']),
      initiatedAt: _s(j['initiatedAt']),
      completedAt: _s(j['completedAt']),
      createdAt: _s(j['created_at'] ?? j['createdAt']),
      updatedAt: _s(j['updated_at'] ?? j['updatedAt']),
      image: _s(p['pujaImage']),
      packageType: _s(pkg['type']),
      pujaId: _s(p['_id'] ?? j['pujaId']),
      videoUrl: _s(j['videoUrl']),
      packagePrice: _n(pkg['price']),
      total: _n(j['totalAmount']),
      orderAmount: _n(j['orderAmount']),
      discount: _n(j['discountAmount']),
      rating: _d(j['rating']),
      isPaymentAttempted: j['isPaymentAttempted'] == true,
      members: (j['customerDetails'] as List? ?? [])
          .whereType<Map>()
          .map((e) => MemberDetails.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      offerings: (j['selectedOfferings'] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => TransactionOffering.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}

String _s(dynamic value) => value == null ? '' : '$value';

num _n(dynamic value) => value is num ? value : num.tryParse('$value') ?? 0;

double _d(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
