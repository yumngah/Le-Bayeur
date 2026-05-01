// ignore_for_file: constant_identifier_names

enum DelegationStatus { PENDING, ACCEPTED, REJECTED, REVOKED }

class Delegation {
  final String id;
  final String ownerId;
  final String delegateEmail;
  final String invitationCode;
  final DateTime invitationExpiresAt;
  final DateTime? acceptedAt;
  final String? delegateId;
  final DelegationStatus status;
  final List<String> permissions;
  final DateTime createdAt;

  Delegation({
    required this.id,
    required this.ownerId,
    required this.delegateEmail,
    required this.invitationCode,
    required this.invitationExpiresAt,
    this.acceptedAt,
    this.delegateId,
    required this.status,
    required this.permissions,
    required this.createdAt,
  });

  factory Delegation.fromJson(Map<String, dynamic> json) {
    return Delegation(
      id: json['id'],
      ownerId: json['owner_id'],
      delegateEmail: json['delegate_email'],
      invitationCode: json['invitation_code'],
      invitationExpiresAt: DateTime.parse(json['invitation_expires_at']),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at']) : null,
      delegateId: json['delegate_id'],
      status: DelegationStatus.values.byName(json['status']),
      permissions: List<String>.from(json['permissions']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'delegate_email': delegateEmail,
      'invitation_code': invitationCode,
      'invitation_expires_at': invitationExpiresAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'delegate_id': delegateId,
      'status': status.name,
      'permissions': permissions,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
