

class Astrologer {
  final String id;
  final String name;
  final String specialization;
  final String language;
  final int experience;
  final int rating;
  final int orders;
  final int originalPrice;
  final int discountedPrice;
  final String imageUrl;

  Astrologer({
    required this.id,
    required this.name,
    required this.specialization,
    required this.language,
    required this.experience,
    required this.rating,
    required this.orders,
    required this.originalPrice,
    required this.discountedPrice,
    required this.imageUrl,
  });

  factory Astrologer.fromJson(Map<String, dynamic> json) {
    return Astrologer(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      language: json['language'] ?? '',
      experience: json['experience'] ?? 0,
      rating: json['rating'] ?? 5,
      orders: json['orders'] ?? 0,
      originalPrice: json['originalPrice'] ?? 20,
      discountedPrice: json['discountedPrice'] ?? 5,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialization': specialization,
      'language': language,
      'experience': experience,
      'rating': rating,
      'orders': orders,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'imageUrl': imageUrl,
    };
  }
}