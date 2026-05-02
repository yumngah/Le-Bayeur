import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/user_model.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final Function(UserRole) onRoleSelected;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: UserRole.values.map((role) {
        final isSelected = selectedRole == role;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: role == UserRole.values.last ? 0 : 8,
            ),
            child: InkWell(
              onTap: () => onRoleSelected(role),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[600] : const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue[600]! : Colors.grey[200]!,
                    width: 1.5,
                  ),
                  boxShadow: isSelected 
                    ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
                ),
                child: Text(
                  _getRoleName(role),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.TENANT:
        return "Locataire";
      case UserRole.OWNER:
        return "Propriétaire";
      case UserRole.BAYEUR:
        return "Bayeur";
      case UserRole.TECHNICIAN:
        return "Technicien";
    }
  }
}
