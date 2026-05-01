// ignore_for_file: constant_identifier_names

enum LeaseStatus {
  PENDING_TENANT,
  PENDING_LANDLORD,
  ACTIVE,
  EXPIRED,
  TERMINATED
}

class LeaseContract {
  final String id;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final double monthlyRent;
  final DateTime startDate;
  final DateTime? endDate;
  final String contractText;
  final String? tenantSignature;
  final String? landlordSignature;
  final DateTime? signedAt;
  final LeaseStatus status;
  final String? propertyName;
  final String? landlordName;
  final String? tenantName;

  LeaseContract({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    required this.monthlyRent,
    required this.startDate,
    this.endDate,
    required this.contractText,
    this.tenantSignature,
    this.landlordSignature,
    this.signedAt,
    this.status = LeaseStatus.PENDING_TENANT,
    this.propertyName,
    this.landlordName,
    this.tenantName,
  });

  factory LeaseContract.fromJson(Map<String, dynamic> json) {
    return LeaseContract(
      id: json['id'],
      propertyId: json['property_id'],
      tenantId: json['tenant_id'],
      landlordId: json['landlord_id'],
      monthlyRent: double.tryParse(json['monthly_rent'].toString()) ?? 0.0,
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      contractText: json['contract_text'],
      tenantSignature: json['tenant_signature'],
      landlordSignature: json['landlord_signature'],
      signedAt: json['signed_at'] != null ? DateTime.parse(json['signed_at']) : null,
      status: _parseStatus(json['status']),
      propertyName: json['property_name'],
      landlordName: json['landlord_name'],
      tenantName: json['tenant_name'],
    );
  }

  static LeaseStatus _parseStatus(String status) {
    switch (status) {
      case 'PENDING_TENANT': return LeaseStatus.PENDING_TENANT;
      case 'PENDING_LANDLORD': return LeaseStatus.PENDING_LANDLORD;
      case 'ACTIVE': return LeaseStatus.ACTIVE;
      case 'EXPIRED': return LeaseStatus.EXPIRED;
      case 'TERMINATED': return LeaseStatus.TERMINATED;
      default: return LeaseStatus.PENDING_TENANT;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'tenant_id': tenantId,
      'landlord_id': landlordId,
      'monthly_rent': monthlyRent,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'contract_text': contractText,
      'tenant_signature': tenantSignature,
      'landlord_signature': landlordSignature,
      'signed_at': signedAt?.toIso8601String(),
      'status': status.name,
    };
  }
}
