import 'puja.dart';

class PujaPackage {
  final String id, type;
  final num price;
  final int members;
  const PujaPackage({
    required this.id,
    required this.type,
    required this.price,
    required this.members,
  });
  factory PujaPackage.fromJson(Map<String, dynamic> j) => PujaPackage(
    id: '${j['_id'] ?? j['sId'] ?? j['id'] ?? ''}',
    type: '${j['type'] ?? 'Standard'}',
    price: j['price'] is num ? j['price'] : num.tryParse('${j['price']}') ?? 0,
    members: int.tryParse('${j['members'] ?? 1}') ?? 1,
  );
}

class PujaBenefit {
  final String header, description;
  const PujaBenefit(this.header, this.description);
  factory PujaBenefit.fromJson(Map<String, dynamic> j) =>
      PujaBenefit('${j['header'] ?? ''}', '${j['description'] ?? ''}');
}

class PujaStep {
  final int number;
  final String title, description;
  const PujaStep(this.number, this.title, this.description);
  factory PujaStep.fromJson(Map<String, dynamic> j) => PujaStep(
    int.tryParse('${j['stepNumber'] ?? 0}') ?? 0,
    '${j['title'] ?? ''}',
    '${j['description'] ?? ''}',
  );
}

class PujaFaq {
  final String question, answer;
  const PujaFaq(this.question, this.answer);
  factory PujaFaq.fromJson(Map<String, dynamic> j) =>
      PujaFaq('${j['question'] ?? ''}', '${j['answer'] ?? ''}');
}

class PujaOffering {
  final String id, title, description, image;
  final num price;
  const PujaOffering({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });
  factory PujaOffering.fromJson(Map<String, dynamic> j) => PujaOffering(
    id: '${j['_id'] ?? j['id'] ?? ''}',
    title: '${j['header'] ?? ''}',
    description: '${j['description'] ?? ''}',
    price: j['price'] is num ? j['price'] : num.tryParse('${j['price']}') ?? 0,
    image: '${j['image'] ?? ''}',
  );
}

class PujaReview {
  final String name, review;
  final double rating;
  const PujaReview(this.name, this.rating, this.review);
  factory PujaReview.fromJson(Map<String, dynamic> j) {
    final u = j['userId'];
    return PujaReview(
      u is Map ? '${u['name'] ?? 'Devotee'}' : 'Devotee',
      double.tryParse('${j['rating'] ?? 0}') ?? 0,
      '${j['review'] ?? ''}',
    );
  }
}

class PujaDetail {
  final Puja puja;
  final double rating;
  final List<String> banners;
  final String about;
  final bool hasPackages;
  final List<PujaPackage> packages;
  final List<PujaBenefit> benefits;
  final List<PujaStep> steps;
  final List<PujaFaq> faqs;
  final List<PujaOffering> offerings;
  final List<PujaReview> reviews;
  const PujaDetail({
    required this.puja,
    required this.rating,
    required this.banners,
    required this.about,
    required this.hasPackages,
    required this.packages,
    required this.benefits,
    required this.steps,
    required this.faqs,
    required this.offerings,
    required this.reviews,
  });
  factory PujaDetail.fromJson(
    Map<String, dynamic> j, {
    List<PujaReview>? reviews,
  }) => PujaDetail(
    puja: Puja.fromJson(j),
    rating: double.tryParse('${j['rating'] ?? 0}') ?? 0,
    banners: (j['bannerImages'] as List? ?? [])
        .map((e) => e.toString())
        .toList(),
    about: '${j['aboutPuja'] ?? j['shortDescription'] ?? ''}',
    hasPackages: j['hasPackages'] != false,
    packages: (j['packages'] as List? ?? [])
        .whereType<Map>()
        .map((e) => PujaPackage.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    benefits: (j['benefits'] as List? ?? [])
        .whereType<Map>()
        .map((e) => PujaBenefit.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    steps: (j['pujaProcess'] as List? ?? [])
        .whereType<Map>()
        .map((e) => PujaStep.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    faqs: (j['faq'] as List? ?? [])
        .whereType<Map>()
        .map((e) => PujaFaq.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    offerings: (j['offerings'] as List? ?? [])
        .whereType<Map>()
        .map((e) => PujaOffering.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    reviews: reviews ?? const [],
  );
}
