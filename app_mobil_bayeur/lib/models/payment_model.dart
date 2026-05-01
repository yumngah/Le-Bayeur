// ignore_for_file: constant_identifier_names

enum PaymentStatus {
  PENDING,
  COMPLETED,
  FAILED,
  CANCELLED
}

enum PaymentMethod {
  MOBILE_MONEY,
  BANK_TRANSFER,
  CARD
}

class Payment {
  final String id;
  final String leaseId;
  final String tenantId;
  final String landlordId;
  final double amount;
  final PaymentMethod method;
  final String? provider; // MTN, ORANGE, VISA, etc.
  final String? referenceNumber;
  final PaymentStatus status;
  final String? invoiceUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? propertyName;

  Payment({
    required this.id,
    required this.leaseId,
    required this.tenantId,
    required this.landlordId,
    required this.amount,
    required this.method,
    this.provider,
    this.referenceNumber,
    this.status = PaymentStatus.PENDING,
    this.invoiceUrl,
    required this.createdAt,
    this.updatedAt,
    this.propertyName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      leaseId: json['lease_id'],
      tenantId: json['tenant_id'],
      landlordId: json['landlord_id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      method: _parseMethod(json['payment_method']),
      provider: json['provider'],
      referenceNumber: json['reference_number'],
      status: _parseStatus(json['status']),
      invoiceUrl: json['invoice_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      propertyName: json['property_name'],
    );
  }

  static PaymentMethod _parseMethod(String? method) {
    switch (method) {
      case 'BANK_TRANSFER': return PaymentMethod.BANK_TRANSFER;
      case 'CARD': return PaymentMethod.CARD;
      default: return PaymentMethod.MOBILE_MONEY;
    }
  }

  static PaymentStatus _parseStatus(String status) {
    switch (status) {
      case 'COMPLETED': return PaymentStatus.COMPLETED;
      case 'FAILED': return PaymentStatus.FAILED;
      case 'CANCELLED': return PaymentStatus.CANCELLED;
      default: return PaymentStatus.PENDING;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'lease_id': leaseId,
      'amount': amount,
      'payment_method': method.name,
      'provider': provider,
      'reference_number': referenceNumber,
    };
  }
}
