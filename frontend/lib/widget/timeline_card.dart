import 'package:flutter/material.dart';
import 'package:seerah_timeline/constants/app_colors.dart';
import 'package:seerah_timeline/widget/custom_network_image.dart';
import '../screen/event_detail_screen.dart';
import 'package:seerah_timeline/services/favorites_service.dart';

class TimelineCard extends StatelessWidget {
  final String id; // Changed to String
  final String year;
  final String title;
  final String description;
  // Optional: local asset path (e.g. 'assets/images/book.png')
  final String? imageAsset;
  // Optional: network image URL
  final String? imageUrl;
  // Lists for structured data
  final List<String> references;
  final List<String> lessons;
  // Full description for detail screen
  final String? fullDescription;
  // Category/period
  final String? category;

  const TimelineCard({
    super.key,
    required this.id, // Changed
    required this.year,
    required this.title,
    required this.description,
    this.imageAsset,
    this.imageUrl,
    this.fullDescription,
    this.category,
    this.references = const [],
    this.lessons = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 👇 Navigate to Event Detail Screen, pass optional image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              id: id, // Added
              title: title,
              date: year,
              period: category ?? "Unknown Period",
              description: fullDescription ?? description,
              imageAsset: imageAsset,
              imageUrl: imageUrl,
              references: references,
              lessons: lessons,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional top image
            if (imageAsset != null || imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 140,
                  child: imageAsset != null
                      ? Image.asset(imageAsset!, fit: BoxFit.cover)
                      : CustomNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            if (imageAsset != null || imageUrl != null)
              const SizedBox(height: 12),
            // Year
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 12),
              child: Text(
                year.isNotEmpty ? year : '',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (year.isNotEmpty) const SizedBox(height: 8),

            // Title with Favorite Icon
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Row(
                children: [
                   // Favorite Icon (Left side)
                   ValueListenableBuilder<List<String>>(
                    valueListenable: FavoritesService().favoriteIds,
                    builder: (context, favIds, _) {
                      final isFav = favIds.contains(id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.pinkAccent : Colors.white70, // Reddish pink on tap
                          size: 20, // Small but not too small
                        ),
                        onPressed: () {
                          FavoritesService().toggleFavorite(id);
                        },
                      );
                    },
                  ),
                  
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        title,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Description
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  description,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13.5,
                    height: 1.3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Read More
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Text(
                  "Read More",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
