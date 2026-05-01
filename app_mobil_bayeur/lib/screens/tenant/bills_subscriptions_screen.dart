import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/bill_subscription_model.dart';
import 'package:intl/intl.dart';

class BillsSubscriptionsScreen extends StatefulWidget {
  const BillsSubscriptionsScreen({super.key});

  @override
  State<BillsSubscriptionsScreen> createState() => _BillsSubscriptionsState();
}

class _BillsSubscriptionsState extends State<BillsSubscriptionsScreen> {
  final List<BillSubscription> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    // Mocking bill data for demonstration
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _bills.clear();
      _bills.addAll([
        BillSubscription(
          id: 'b1',
          userId: 'u1',
          type: BillType.ELECTRICITY,
          title: 'Facture ENEO - Mars',
          amount: 24500,
          dueDate: DateTime.now().add(const Duration(days: 5)),
          isPaid: false,
        ),
        BillSubscription(
          id: 'b2',
          userId: 'u1',
          type: BillType.SUBSCRIPTION,
          title: 'Abonnement Netflix',
          amount: 8500,
          dueDate: DateTime.now().add(const Duration(days: 12)),
          isPaid: true,
          provider: SubscriptionProvider.NETFLIX,
        ),
        BillSubscription(
          id: 'b3',
          userId: 'u1',
          type: BillType.SUBSCRIPTION,
          title: 'Canal+ Tout Canal',
          amount: 25000,
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
          isPaid: false,
          provider: SubscriptionProvider.CANAL_PLUS,
        ),
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Factures & Abonnements", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildMonthlySummary(),
              const SizedBox(height: 32),
              _buildSectionHeader("À venir", Colors.orange),
              ..._bills.where((b) => !b.isPaid && b.dueDate.isAfter(DateTime.now())).map((b) => _buildBillCard(b)),
              const SizedBox(height: 24),
              _buildSectionHeader("En retard", Colors.red),
              ..._bills.where((b) => !b.isPaid && b.dueDate.isBefore(DateTime.now())).map((b) => _buildBillCard(b)),
              const SizedBox(height: 24),
              _buildSectionHeader("Déjà payé", Colors.green),
              ..._bills.where((b) => b.isPaid).map((b) => _buildBillCard(b)),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    final total = _bills.fold<double>(0, (sum, b) => sum + b.amount);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.blue[900], borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Text("Dépenses estimées ce mois", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text("${NumberFormat.decimalPattern().format(total)} FCFA", style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBillCard(BillSubscription bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        children: [
          _getProviderIcon(bill),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Échéance: ${DateFormat('dd MMM yyyy').format(bill.dueDate)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${NumberFormat.decimalPattern().format(bill.amount)} F", style: const TextStyle(fontWeight: FontWeight.bold)),
              if (!bill.isPaid)
                TextButton(
                  onPressed: () {},
                  child: const Text("Payer", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getProviderIcon(BillSubscription bill) {
    IconData icon;
    Color color;
    switch (bill.type) {
      case BillType.ELECTRICITY:
        icon = Icons.electric_bolt;
        color = Colors.orange;
        break;
      case BillType.WATER:
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      case BillType.SUBSCRIPTION:
        icon = Icons.subscriptions;
        color = Colors.purple;
        break;
      default:
        icon = Icons.receipt;
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
