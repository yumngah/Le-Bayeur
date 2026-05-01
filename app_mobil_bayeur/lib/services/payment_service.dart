import 'package:app_mobil_bayeur/models/payment_model.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class PaymentService {
  final ApiService _api;

  PaymentService(this._api);

  Future<Payment> initiatePayment(String leaseId, double amount, PaymentMethod method, {String? provider}) async {
    final response = await _api.post('/api/payments', data: {
      'lease_id': leaseId,
      'amount': amount,
      'payment_method': method.name,
      'provider': provider,
    });
    return Payment.fromJson(response.data);
  }

  Future<Payment> confirmPayment(String paymentId, String transactionId, {String? proofUrl}) async {
    final response = await _api.post('/api/payments/$paymentId/confirm', data: {
      'transaction_id': transactionId,
      'proof_url': proofUrl,
    });
    return Payment.fromJson(response.data);
  }

  Future<List<Payment>> getPaymentsByLease(String leaseId) async {
    final response = await _api.get('/api/payments/lease/$leaseId');
    return (response.data as List).map((p) => Payment.fromJson(p)).toList();
  }

  Future<List<Map<String, dynamic>>> getPaymentCalendar(int year, int month) async {
    final response = await _api.get('/api/payments/calendar', params: {
      'year': year,
      'month': month,
    });
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> sendPaymentReminder(String leaseId) async {
    await _api.post('/api/payments/remind/$leaseId');
  }
}
