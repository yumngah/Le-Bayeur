import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/providers/delegation_provider.dart';
import 'package:share_plus/share_plus.dart';

class CreateDelegationLinkScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const CreateDelegationLinkScreen({super.key, required this.propertyId});

  @override
  ConsumerState<CreateDelegationLinkScreen> createState() => _CreateDelegationLinkScreenState();
}

class _CreateDelegationLinkScreenState extends ConsumerState<CreateDelegationLinkScreen> {
  final _emailController = TextEditingController();
  final List<String> _permissions = ['MANAGE_LEASES', 'MANAGE_PAYMENTS', 'MANAGE_MAINTENANCE'];
  final List<String> _selectedPermissions = ['MANAGE_LEASES'];
  
  bool _isGenerating = false;
  String? _generatedCode;

  Future<void> _handleGenerate() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez saisir l'email du délégué")));
      return;
    }

    setState(() => _isGenerating = true);
    
    try {
      final delegation = await ref.read(delegationServiceProvider).createInvitation(
        _emailController.text,
        _selectedPermissions,
      );
      
      setState(() {
        _generatedCode = delegation.invitationCode;
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
    }
  }

  void _shareCode() {
    if (_generatedCode != null) {
      Share.share(
        "Bonjour, je vous invite à gérer mon bien sur l'application Bayeurs. Utilisez ce code d'invitation : $_generatedCode. Validité : 30 jours.",
        subject: "Invitation de gestion déléguée - Bayeurs",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Déléguer la gestion", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Ma Main Droite",
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            const SizedBox(height: 12),
            const Text(
              "Invitez une personne de confiance pour gérer les locations, paiements et maintenances de ce bien.",
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _emailController,
              label: "Email du délégué",
              hint: "votre.delegue@email.com",
              icon: Icons.alternate_email,
            ),
            const SizedBox(height: 32),
            Text("Permissions accordées", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._permissions.map((p) => CheckboxListTile(
                  title: Text(_translatePermission(p)),
                  value: _selectedPermissions.contains(p),
                  onChanged: (val) {
                    setState(() {
                      if (val!) {
                        _selectedPermissions.add(p);
                      } else {
                        _selectedPermissions.remove(p);
                      }
                    });
                  },
                )),
            const SizedBox(height: 48),
            if (_generatedCode == null)
              ElevatedButton(
                onPressed: _isGenerating ? null : _handleGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isGenerating
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Générer le code d'invitation"),
              )
            else
              _buildSuccessState(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green[200]!)),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
          const SizedBox(height: 16),
          const Text("Code généré avec succès !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_generatedCode!, style: GoogleFonts.firaCode(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generatedCode!));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code copié !")));
                  },
                  icon: const Icon(Icons.copy, size: 20, color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _shareCode,
            icon: const Icon(Icons.share),
            label: const Text("Partager le lien"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  String _translatePermission(String p) {
    switch (p) {
      case 'MANAGE_LEASES':
        return "Gérer les contrats de bail";
      case 'MANAGE_PAYMENTS':
        return "Gérer les paiements de loyer";
      case 'MANAGE_MAINTENANCE':
        return "Gérer les demandes de maintenance";
      default:
        return p;
    }
  }
}
