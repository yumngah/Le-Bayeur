import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/user_model.dart';
import 'package:app_mobil_bayeur/providers/auth_provider.dart';
import 'package:app_mobil_bayeur/widgets/role_selector.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.TENANT;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Créer un compte",
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rejoignez la communauté Bayeurs dès aujourd'hui.",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Username
                _buildTextField(
                  controller: _usernameController,
                  label: "Nom d'utilisateur",
                  hint: "Ex: john_doe",
                  icon: Icons.person_outline,
                  validator: (v) => (v?.length ?? 0) < 3 ? "Minimum 3 caractères" : null,
                ),
                const SizedBox(height: 20),

                // Email
                _buildTextField(
                  controller: _emailController,
                  label: "Adresse Email",
                  hint: "votre@email.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v ?? '') ? "Email invalide" : null,
                ),
                const SizedBox(height: 20),

                // Phone
                _buildTextField(
                  controller: _phoneController,
                  label: "Numéro de téléphone",
                  hint: "+237...",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v?.length ?? 0) < 9 ? "Numéro invalide" : null,
                ),
                const SizedBox(height: 20),

                // Password
                _buildTextField(
                  controller: _passwordController,
                  label: "Mot de passe",
                  hint: "********",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => (v?.length ?? 0) < 8 ? "Minimum 8 caractères" : null,
                ),
                const SizedBox(height: 24),

                // Role Selector
                RoleSelector(
                  selectedRole: _selectedRole,
                  onRoleSelected: (role) => setState(() => _selectedRole = role),
                ),
                const SizedBox(height: 40),

                // Submit Button
                ElevatedButton(
                  onPressed: authState.status == AuthStatus.authenticating ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: authState.status == AuthStatus.authenticating
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("S'inscrire", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                ),

                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    authState.errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.red, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).signup({
        'username': _usernameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'password': _passwordController.text,
        'role': _selectedRole.name,
      });
    }
  }
}
