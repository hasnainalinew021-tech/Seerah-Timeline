import 'package:flutter/material.dart';
import 'package:seerah_timeline/constants/app_colors.dart';
import 'package:seerah_timeline/screen/active_quiz_screen.dart';
import 'package:seerah_timeline/widget/custom_network_image.dart';

class EventDetailScreen extends StatelessWidget {
  final String title;
  final String date;
  final String period;
  final String description;
  // Optional image (either local asset or network)
  final String? imageAsset;
  final String? imageUrl;
  
  // Lists for structured data
  final List<String> references;
  final List<String> lessons;

  const EventDetailScreen({
    super.key,
    required this.title,
    required this.date,
    required this.period,
    required this.description,
    this.imageAsset,
    this.imageUrl,
    this.references = const [],
    this.lessons = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.share_outlined, color: Color(0xFF0D9488)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optional banner image
              if (imageAsset != null || imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: imageAsset != null
                        ? Image.asset(imageAsset!, fit: BoxFit.cover)
                        : CustomNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: Colors.teal.shade300,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.white70,
                                  size: 44,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

              if (imageAsset != null || imageUrl != null)
                const SizedBox(height: 16),
              
              // 🕌 Title Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF0D9488),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Color(0xFF0D9488),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Noto Nastaliq Urdu',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              
              // Date && Period Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   if (period.isNotEmpty && period != "Unknown Period")
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        period,
                        style: const TextStyle(
                          color: Color(0xFF0D9488),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                   if (date.isNotEmpty)
                    Text(
                      date,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Colors.black54, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // 📖 Description Box
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  description,
                  textAlign: TextAlign.right, // RTL for Urdu text
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    height: 1.8,
                    fontFamily: 'Noto Nastaliq Urdu', // Better Urdu font
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 📚 Collapsible References
               _buildExpandableTile(
                  "References",
                  Icons.menu_book_outlined,
                  references,
                  context,
                ),
                
               const SizedBox(height: 12),

              // 💡 Collapsible Lessons
               _buildExpandableTile(
                  "Lessons & Wisdom",
                  Icons.lightbulb_outline,
                  lessons,
                  context,
                ),

                const SizedBox(height: 30),

                // 📝 Take Quiz Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActiveQuizScreen(
                            eventTitle: title,
                            eventContent: description,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.quiz_outlined, color: Colors.white),
                    label: const Text(
                      "Take Quiz",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable Expandable Tile
  Widget _buildExpandableTile(String title, IconData icon, List<String> items, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            side: BorderSide.none,
          ),
          leading: Icon(icon, color: const Color(0xFF0D9488)),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0D9488),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          iconColor: const Color(0xFF0D9488),
          collapsedIconColor: const Color(0xFF0D9488),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: items.isEmpty 
          ? [
               const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "No content available.",
                     style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
               )
            ]
          : [
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end, // Align right for Urdu
                children: [
                   Expanded(
                    child: Text(
                      item,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Noto Nastaliq Urdu',
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: Color(0xFF0D9488)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
