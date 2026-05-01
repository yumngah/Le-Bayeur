import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/property_listing_model.dart';
import 'package:intl/intl.dart';

class PropertyCardInstagramStyle extends StatefulWidget {
  final PropertyListing property;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onApply;

  const PropertyCardInstagramStyle({
    super.key,
    required this.property,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onApply,
  });

  @override
  State<PropertyCardInstagramStyle> createState() => _PropertyCardInstagramState();
}

class _PropertyCardInstagramState extends State<PropertyCardInstagramStyle> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_CM', symbol: 'FCFA', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue[100],
                  child: Text(widget.property.ownerName.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.property.ownerName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          Text(" ${widget.property.ownerRating}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),

          // Photo Carousel
          Stack(
            children: [
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: widget.property.images.length,
                  onPageChanged: (index) => setState(() => _currentImageIndex = index),
                  itemBuilder: (context, index) {
                    return Image.network(
                      widget.property.images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              if (widget.property.images.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                    child: Text("${_currentImageIndex + 1}/${widget.property.images.length}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(widget.property.isLiked ? Icons.favorite : Icons.favorite_border, color: widget.property.isLiked ? Colors.red : Colors.black),
                  onPressed: widget.onLike,
                ),
                IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: widget.onComment),
                IconButton(icon: const Icon(Icons.send_outlined), onPressed: widget.onShare),
                const Spacer(),
                TextButton(
                  onPressed: widget.onApply,
                  style: TextButton.styleFrom(foregroundColor: Colors.blue[900]),
                  child: Text(widget.property.status == PropertyStatus.FOR_RENT ? "POSTULER" : "ACHETER", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.property.likesCount} J'aime", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(widget.property.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text(widget.property.type.name, style: TextStyle(color: Colors.blue[800], fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.property.status == PropertyStatus.FOR_RENT 
                    ? "${currencyFormat.format(widget.property.rentPrice)} / mois"
                    : currencyFormat.format(widget.property.salePrice),
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    children: [
                      TextSpan(text: widget.property.ownerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: " "),
                      TextSpan(text: widget.property.description),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: widget.onComment,
                  child: Text("Voir les ${widget.property.commentsCount} commentaires", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
