// ignore_for_file: constant_identifier_names

enum BillType { ELECTRICITY, WATER, SUBSCRIPTION, OTHER }
enum SubscriptionProvider { CANAL_PLUS, DSTV, STARS, NETFLIX, PRIME_VIDEO, OTHER }

class BillSubscription {
  final String id;
  final String userId;
  final BillType type;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String? invoiceUrl;
  final SubscriptionProvider? provider;
  final int? reminderDays; // 30, 7, 1 etc.

  BillSubscription({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.invoiceUrl,
    this.provider,
    this.reminderDays,
  });

  factory BillSubscription.fromJson(Map<String, dynamic> json) {
    return BillSubscription(
      id: json['id'],
      userId: json['user_id'],
      type: BillType.values.byName(json['type'] ?? 'OTHER'),
      title: json['title'],
      amount: double.parse(json['amount'].toString()),
      dueDate: DateTime.parse(json['due_date']),
      isPaid: json['is_paid'] ?? false,
      invoiceUrl: json['invoice_url'],
      provider: json['provider'] != null 
          ? SubscriptionProvider.values.byName(json['provider']) 
          : null,
      reminderDays: json['reminder_days'],
    );
  }
}
