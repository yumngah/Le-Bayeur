// ignore_for_file: constant_identifier_names

enum MaintenanceType { ELECTRICITY, PLUMBING, GENERAL }
enum MaintenanceFrequency { WEEKLY, MONTHLY, YEARLY, ONCE }
enum MaintenanceStatus { SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED }
enum RequestStatus { PENDING, IN_PROGRESS, COMPLETED, REJECTED }
enum Urgency { NORMAL, URGENT }

class Technician {
  final String id;
  final String userId;
  final String? name;
  final String? phone;
  final MaintenanceType specialty;
  final int? yearsExperience;
  final String? qualificationDocumentUrl;
  final bool isAvailable;
  final double averageRating;
  final String? location;
  final String? bio;
  final bool isVerified;

  Technician({
    required this.id,
    required this.userId,
    this.name,
    this.phone,
    required this.specialty,
    this.yearsExperience,
    this.qualificationDocumentUrl,
    required this.isAvailable,
    required this.averageRating,
    this.location,
    this.bio,
    this.isVerified = false,
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'],
      userId: json['user_id'],
      name: json['username'],
      phone: json['phone_number'],
      specialty: MaintenanceType.values.byName(json['specialty'] ?? 'GENERAL'),
      yearsExperience: json['years_experience'],
      qualificationDocumentUrl: json['qualification_document_url'],
      isAvailable: json['is_available'] ?? true,
      averageRating: json['average_rating'] != null ? double.parse(json['average_rating'].toString()) : 0.0,
      location: json['location'],
      bio: json['bio'],
      isVerified: json['is_verified'] ?? false,
    );
  }
}

class MaintenanceRequest {
  final String id;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final MaintenanceType type;
  final String description;
  final Urgency urgency;
  final RequestStatus status;
  final List<String> photos;
  final String? assignedTechnicianId;
  final DateTime? completedAt;
  final double? actualCost;
  final String? propertyName;

  MaintenanceRequest({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    required this.type,
    required this.description,
    required this.urgency,
    required this.status,
    required this.photos,
    this.assignedTechnicianId,
    this.completedAt,
    this.actualCost,
    this.propertyName,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'],
      propertyId: json['property_id'],
      tenantId: json['tenant_id'],
      landlordId: json['landlord_id'],
      type: MaintenanceType.values.byName(json['type'] ?? 'GENERAL'),
      description: json['description'],
      urgency: Urgency.values.byName(json['urgency'] ?? 'NORMAL'),
      status: RequestStatus.values.byName(json['status'] ?? 'PENDING'),
      photos: json['photos'] != null ? List<String>.from(json['photos']) : [],
      assignedTechnicianId: json['assigned_technician_id'],
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      actualCost: json['actual_cost'] != null ? double.parse(json['actual_cost'].toString()) : null,
      propertyName: json['property_name'],
    );
  }
}

class InterventionReport {
  final String id;
  final String maintenanceId;
  final String description;
  final List<String> beforePhotos;
  final List<String> afterPhotos;
  final double cost;
  final String? recommendations;
  final DateTime createdAt;

  InterventionReport({
    required this.id,
    required this.maintenanceId,
    required this.description,
    required this.beforePhotos,
    required this.afterPhotos,
    required this.cost,
    this.recommendations,
    required this.createdAt,
  });

  factory InterventionReport.fromJson(Map<String, dynamic> json) {
    return InterventionReport(
      id: json['id'],
      maintenanceId: json['maintenance_id'],
      description: json['description'],
      beforePhotos: List<String>.from(json['before_photos'] ?? []),
      afterPhotos: List<String>.from(json['after_photos'] ?? []),
      cost: double.parse(json['cost'].toString()),
      recommendations: json['recommendations'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Evaluation {
  final String id;
  final String targetUserId;
  final String reviewerId;
  final int rating;
  final String? comment;
  final String reviewerRole; // LANDLORD, TENANT
  final DateTime createdAt;

  Evaluation({
    required this.id,
    required this.targetUserId,
    required this.reviewerId,
    required this.rating,
    this.comment,
    required this.reviewerRole,
    required this.createdAt,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'],
      targetUserId: json['target_id'],
      reviewerId: json['reviewer_id'],
      rating: json['rating'],
      comment: json['comment'],
      reviewerRole: json['reviewer_role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
