import 'package:flutter/material.dart';
import 'package:app_mobil_bayeur/models/property_listing_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 500000);
  PropertyStanding? _selectedStanding;
  PropertyType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Rechercher un quartier, un bien...",
            border: InputBorder.none,
          ),
          onChanged: (val) => setState(() {}),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Filtres Avancés", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            
            const Text("Budget mensuel (FCFA)", style: TextStyle(fontWeight: FontWeight.bold)),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000000,
              divisions: 20,
              labels: RangeLabels(
                _priceRange.start.round().toString(),
                _priceRange.end.round().toString(),
              ),
              onChanged: (values) => setState(() => _priceRange = values),
            ),
            
            const SizedBox(height: 24),
            const Text("Type de bien", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: PropertyType.values.map((type) => ChoiceChip(
                label: Text(type.name),
                selected: _selectedType == type,
                onSelected: (_) => setState(() => _selectedType = type),
              )).toList(),
            ),
            
            const SizedBox(height: 24),
            const Text("Standing", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: PropertyStanding.values.map((s) => ChoiceChip(
                label: Text(s.name),
                selected: _selectedStanding == s,
                onSelected: (_) => setState(() => _selectedStanding = s),
              )).toList(),
            ),
            
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Appliquer les filtres"),
            ),
          ],
        ),
      ),
    );
  }
}
