import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/property_model.dart';
import 'package:app_mobil_bayeur/providers/property_provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_mobil_bayeur/screens/delegation/create_delegation_link_screen.dart';

class PropertyDetailsScreen extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyDetailProvider(propertyId));
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: propertyAsync.when(
        data: (property) => CustomScrollView(
          slivers: [
            _buildAppBar(context, property),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          property.name,
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currencyFormat.format(property.rentPrice ?? property.salePrice ?? 0),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(property.location, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildStatsGrid(property),
                    const SizedBox(height: 32),
                    Text("Description", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      property.description ?? "Pas de description fournie.",
                      style: TextStyle(height: 1.5, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 40),
                    _buildActions(context, property),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erreur: $err")),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Property property) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: property.imageUrls.isNotEmpty
            ? PageView.builder(
                itemCount: property.imageUrls.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: property.imageUrls[index],
                    fit: BoxFit.cover,
                  );
                },
              )
            : Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 80)),
      ),
    );
  }

  Widget _buildStatsGrid(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.visibility, "${property.viewCount}", "Vues"),
          _buildStatItem(Icons.home, property.type.name, "Type"),
          _buildStatItem(Icons.star, property.standing.name, "Standing"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateDelegationLinkScreen(propertyId: property.id)),
            );
          },
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text("Déléguer la gestion"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined),
          label: const Text("Modifier les informations"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
