import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/user_model.dart';
import 'package:app_mobil_bayeur/providers/auth_provider.dart';
import 'package:app_mobil_bayeur/screens/auth/signup_screen.dart';
import 'package:app_mobil_bayeur/screens/auth/verification_screen.dart';

import 'package:app_mobil_bayeur/screens/property/property_list_screen.dart';

class RoleBasedRouting extends ConsumerWidget {
  const RoleBasedRouting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
      case AuthStatus.unauthenticated:
        return const SignupScreen();
      
      case AuthStatus.authenticating:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case AuthStatus.needsVerification:
        return const VerificationScreen(type: 'email');

      case AuthStatus.authenticated:
        return _buildHomeByRole(authState.user!.role);

      case AuthStatus.error:
        return const SignupScreen(); 
    }
  }

  Widget _buildHomeByRole(UserRole role) {
    if (role == UserRole.BAYEUR || role == UserRole.OWNER) {
      return const PropertyListScreen();
    }

    String title = "";
    String subtitle = "";
    IconData icon = Icons.home;

    switch (role) {
      case UserRole.TENANT:
        title = "Découvrez des biens";
        subtitle = "Feed type Instagram à venir...";
        icon = Icons.grid_view_rounded;
        break;
      case UserRole.TECHNICIAN:
        title = "Espace Technicien";
        subtitle = "Formulaire de vérification des compétences...";
        icon = Icons.engineering_rounded;
        break;
      default:
        break;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
