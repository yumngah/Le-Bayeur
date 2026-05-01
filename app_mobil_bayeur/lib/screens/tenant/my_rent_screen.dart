import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/screens/maintenance/maintenance_request_screen.dart';
import 'package:app_mobil_bayeur/screens/calendar/rent_calendar_screen.dart';

class MyRentScreen extends StatefulWidget {
  const MyRentScreen({super.key});

  @override
  State<MyRentScreen> createState() => _MyRentState();
}

class _MyRentState extends State<MyRentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Mon Loyer", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActivePropertyCard(),
            const SizedBox(height: 24),
            _buildPaymentStatus(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 32),
            _buildLandlordInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePropertyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue[900], borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.blue[900]!.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bien actuellement loué", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Text("Appartement Akwa Center", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Douala, Akwa - Rue de la joie", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Loyer mensuel", style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text("150,000 FCFA", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue[900], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text("Payer", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 60, height: 60, child: CircularProgressIndicator(value: 0.7, backgroundColor: Colors.grey[200], color: Colors.green, strokeWidth: 8)),
              const Text("22j", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Prochain paiement", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Le 01 Mai 2024", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildActionItem(Icons.calendar_month, "Calendrier", Colors.blue, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RentCalendarScreen(leaseId: '1')));
        }),
        _buildActionItem(Icons.home_repair_service, "Maintenance", Colors.orange, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceRequestScreen(propertyId: '1')));
        }),
        _buildActionItem(Icons.receipt_long, "Factures", Colors.purple, () {}),
        _buildActionItem(Icons.chat_outlined, "Chat Bayeur", Colors.green, () {}),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLandlordInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Votre Bayeur", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: Colors.blue[100], child: const Icon(Icons.person, color: Colors.blue)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Emmanuel Ngah", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("+237 6XX XX XX XX", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.phone, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
}
