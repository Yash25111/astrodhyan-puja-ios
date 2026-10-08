class Puja {
  final String id;
  final String title;
  final String slug;
  final String pujaImage;
  final String pujaDate;
  final String shortDescription;
  final String location;
  final String homePageVerticalImage;
  final num displayedPrice;
  final num actualPrice;
  final double rating;
  final bool isPopular;
  final bool isRecurring;
  final bool isFeatured;

  const Puja({
    required this.id,
    required this.title,
    required this.slug,
    required this.pujaImage,
    required this.displayedPrice,
    required this.actualPrice,
    required this.pujaDate,
    required this.shortDescription,
    required this.isPopular,
    required this.location,
    required this.homePageVerticalImage,
    required this.rating,
    required this.isRecurring,
    required this.isFeatured,
  });

  String get bannerImage =>
      homePageVerticalImage.isNotEmpty ? homePageVerticalImage : pujaImage;

  factory Puja.fromJson(Map<String, dynamic> j) {
    return Puja(
      id: _s(j['_id']),
      title: _s(j['title']),
      slug: _s(j['slug']),
      pujaImage: _s(j['pujaImage']),
      displayedPrice: _n(j['displayedPrice']),
      actualPrice: _n(j['actualPrice']),
      pujaDate: _s(j['pujaDate']),
      shortDescription: _s(j['shortDescription']),
      isPopular: j['isPopular'] == true,
      location: _s(j['location']),
      homePageVerticalImage: _s(j['homePageVerticalImage']),
      rating: _d(j['rating']),
      isRecurring: j['isRecurring'] == true,
      isFeatured: j['isFeatured'] == true,
    );
  }

  static String _s(dynamic v) => v == null ? '' : '$v';
  static num _n(dynamic v) => v is num ? v : num.tryParse('$v') ?? 0;
  static double _d(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
}

class PujaHomeData {
  final List<Puja> specialPujas;
  final List<Puja> pujas;

  const PujaHomeData({required this.specialPujas, required this.pujas});

  Puja? get specialPuja => specialPujas.isEmpty ? null : specialPujas.first;

  factory PujaHomeData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final special = data['specialPuja'];
    final specialList = data['specialPujas'];
    final pujas = data['pujas'];
    final parsedSpecialPujas = specialList is List
        ? specialList
              .whereType<Map>()
              .map((e) => Puja.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <Puja>[];

    return PujaHomeData(
      specialPujas: parsedSpecialPujas.isNotEmpty
          ? parsedSpecialPujas
          : [
              if (special is Map)
                Puja.fromJson(Map<String, dynamic>.from(special)),
            ],
      pujas: pujas is List
          ? pujas
                .whereType<Map>()
                .map((e) => Puja.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}
