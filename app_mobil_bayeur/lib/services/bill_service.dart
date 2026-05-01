import 'package:app_mobil_bayeur/models/bill_subscription_model.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class BillService {
  final ApiService _api;

  BillService(this._api);

  Future<List<BillSubscription>> getMyBills() async {
    final response = await _api.get('/bills/my');
    return (response.data as List).map((json) => BillSubscription.fromJson(json)).toList();
  }

  Future<BillSubscription> createBill(Map<String, dynamic> data) async {
    final response = await _api.post('/bills', data: data);
    return BillSubscription.fromJson(response.data);
  }

  Future<void> markAsPaid(String billId) async {
    await _api.post('/bills/$billId/pay');
  }

  Future<void> deleteBill(String billId) async {
    await _api.delete('/bills/$billId');
  }

  Future<Map<DateTime, List<BillSubscription>>> getBillCalendar(int year, int month) async {
    final response = await _api.get('/bills/calendar', params: {
      'year': year,
      'month': month,
    });
    
    final Map<DateTime, List<BillSubscription>> calendar = {};
    (response.data as Map<String, dynamic>).forEach((key, value) {
      final date = DateTime.parse(key);
      calendar[date] = (value as List).map((json) => BillSubscription.fromJson(json)).toList();
    });
    return calendar;
  }
}
