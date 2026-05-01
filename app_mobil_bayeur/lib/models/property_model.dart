// ignore_for_file: constant_identifier_names

enum PropertyType { HOUSE, APARTMENT, STUDIO, ROOM, BUILDING }
enum PropertyStatus { FOR_SALE, FOR_RENT, SOLD, OCCUPIED }
enum PropertyStanding { SIMPLE, STANDARD, LUXURY }
enum VerificationStatus { PENDING, APPROVED, REJECTED }

class Property {
  final String id;
  final String ownerId;
  final String name;
  final String location;
  final double? latitude;
  final double? longitude;
  final PropertyType type;
  final double? salePrice;
  final double? rentPrice;
  final PropertyStatus status;
  final PropertyStanding standing;
  final String? description;
  final VerificationStatus verificationStatus;
  final String? verificationDocumentUrl;
  final List<String> imageUrls;
  final int viewCount;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.location,
    this.latitude,
    this.longitude,
    required this.type,
    this.salePrice,
    this.rentPrice,
    required this.status,
    required this.standing,
    this.description,
    required this.verificationStatus,
    this.verificationDocumentUrl,
    required this.imageUrls,
    required this.viewCount,
    required this.createdAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      ownerId: json['owner_id'] ?? json['ownerId'],
      name: json['name'],
      location: json['location'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      type: PropertyType.values.byName(json['type']),
      salePrice: json['sale_price'] != null ? double.tryParse(json['sale_price'].toString()) : null,
      rentPrice: json['rent_price'] != null ? double.tryParse(json['rent_price'].toString()) : null,
      status: PropertyStatus.values.byName(json['status']),
      standing: PropertyStanding.values.byName(json['standing']),
      description: json['description'],
      verificationStatus: VerificationStatus.values.byName(json['verification_status'] ?? 'PENDING'),
      verificationDocumentUrl: json['verification_document_url'] ?? json['verificationDocumentUrl'],
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls']) 
          : (json['images'] != null ? List<String>.from(json['images']) : []),
      viewCount: json['view_count'] ?? json['viewCount'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.name,
      'sale_price': salePrice,
      'rent_price': rentPrice,
      'status': status.name,
      'standing': standing.name,
      'description': description,
      'verification_status': verificationStatus.name,
      'verification_document_url': verificationDocumentUrl,
      'image_urls': imageUrls,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
