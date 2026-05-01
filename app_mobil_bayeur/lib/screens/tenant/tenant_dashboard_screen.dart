import 'package:flutter/material.dart';
import 'package:app_mobil_bayeur/screens/tenant/home_feed_screen.dart';
import 'package:app_mobil_bayeur/screens/tenant/my_rent_screen.dart';
import 'package:app_mobil_bayeur/screens/tenant/bills_subscriptions_screen.dart';
import 'package:app_mobil_bayeur/screens/tenant/profile_screen.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeFeedScreen(),
    const MyRentScreen(),
    const BillsSubscriptionsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.home_work_outlined), activeIcon: Icon(Icons.home_work), label: "Mon Loyer"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: "Dépenses"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
