// ignore_for_file: constant_identifier_names

enum PropertyStanding { SIMPLE, STANDARD, LUXURY }
enum PropertyType { HOUSE, APARTMENT, STUDIO, ROOM }
enum PropertyStatus { FOR_RENT, FOR_SALE, SOLD, OCCUPIED }

class PropertyListing {
  final String id;
  final String ownerId;
  final String ownerName;
  final double ownerRating;
  final String name;
  final String location;
  final PropertyType type;
  final PropertyStatus status;
  final PropertyStanding standing;
  final double? rentPrice;
  final double? salePrice;
  final String description;
  final List<String> images;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;

  PropertyListing({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerRating,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
    required this.standing,
    this.rentPrice,
    this.salePrice,
    required this.description,
    required this.images,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory PropertyListing.fromJson(Map<String, dynamic> json) {
    return PropertyListing(
      id: json['id'],
      ownerId: json['owner_id'],
      ownerName: json['owner_name'] ?? 'Bayeur',
      ownerRating: json['owner_rating'] != null ? double.parse(json['owner_rating'].toString()) : 4.5,
      name: json['name'],
      location: json['location'],
      type: PropertyType.values.byName(json['type'] ?? 'APARTMENT'),
      status: PropertyStatus.values.byName(json['status'] ?? 'FOR_RENT'),
      standing: PropertyStanding.values.byName(json['standing'] ?? 'STANDARD'),
      rentPrice: json['rent_price'] != null ? double.parse(json['rent_price'].toString()) : null,
      salePrice: json['sale_price'] != null ? double.parse(json['sale_price'].toString()) : null,
      description: json['description'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
