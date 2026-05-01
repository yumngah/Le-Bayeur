import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/screens/onboarding/role_based_routing.dart';

void main() {
  runApp(
    const ProviderScope(
      child: BayeursApp(),
    ),
  );
}

class BayeursApp extends StatelessWidget {
  const BayeursApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bayeurs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const RoleBasedRouting(),
    );
  }
}
