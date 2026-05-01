import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/property_listing_model.dart';
import 'package:app_mobil_bayeur/widgets/property_card_instagram_style.dart';
import 'package:app_mobil_bayeur/screens/tenant/search_screen.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedState();
}

class _HomeFeedState extends ConsumerState<HomeFeedScreen> {
  final List<PropertyListing> _properties = [];
  bool _isLoading = true;
  bool _isBuyerMode = false; // Toggle between Rent and Buy

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    // Mocking feed data for demonstration
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _properties.clear();
      _properties.addAll([
        PropertyListing(
          id: '1',
          ownerId: 'o1',
          ownerName: 'Emmanuel Ngah',
          ownerRating: 4.8,
          name: 'Villa Standing Bastos',
          location: 'Yaoundé, Bastos',
          type: PropertyType.HOUSE,
          status: _isBuyerMode ? PropertyStatus.FOR_SALE : PropertyStatus.FOR_RENT,
          standing: PropertyStanding.LUXURY,
          rentPrice: 450000,
          salePrice: 150000000,
          description: 'Splendide villa d\'architecte avec piscine et jardin privatif.',
          images: [
            'https://images.unsplash.com/photo-1580587771525-78b9dba3b914',
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
          ],
          likesCount: 128,
          commentsCount: 45,
          createdAt: DateTime.now(),
        ),
        PropertyListing(
          id: '2',
          ownerId: 'o2',
          ownerName: 'Sandrine K.',
          ownerRating: 4.5,
          name: 'Appartement Akwa Center',
          location: 'Douala, Akwa',
          type: PropertyType.APARTMENT,
          status: _isBuyerMode ? PropertyStatus.FOR_SALE : PropertyStatus.FOR_RENT,
          standing: PropertyStanding.STANDARD,
          rentPrice: 150000,
          salePrice: 45000000,
          description: 'Appartement moderne, proche de toutes commodités, idéal pour jeunes cadres.',
          images: [
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
          ],
          likesCount: 56,
          commentsCount: 12,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Bayeurs",
          style: GoogleFonts.leckerliOne(color: Colors.blue[900], fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[800]),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
          ),
          IconButton(icon: Icon(Icons.notifications_none, color: Colors.grey[800]), onPressed: () {}),
          _buildModeToggle(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _properties.length,
                itemBuilder: (context, index) {
                  return PropertyCardInstagramStyle(
                    property: _properties[index],
                    onLike: () => setState(() {}), // Simplified
                    onComment: () {},
                    onShare: () {},
                    onApply: () {},
                  );
                },
              ),
            ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              _isBuyerMode = !_isBuyerMode;
              _isLoading = true;
            });
            _loadFeed();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isBuyerMode ? Colors.orange[100] : Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isBuyerMode ? "BUY" : "RENT",
              style: TextStyle(
                fontSize: 10,
                color: _isBuyerMode ? Colors.orange[900] : Colors.blue[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
