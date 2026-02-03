import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seerah_timeline/constants/app_colors.dart';
import 'package:seerah_timeline/screen/video_player_screen.dart';
import 'package:seerah_timeline/service/favorites_service.dart';

class MultimediaTab extends StatefulWidget {
  const MultimediaTab({super.key});

  @override
  State<MultimediaTab> createState() => _MultimediaTabState();
}

class _MultimediaTabState extends State<MultimediaTab> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _mediaFuture;

  @override
  void initState() {
    super.initState();
    _mediaFuture = _fetchMediaEvents();
  }

  Future<List<Map<String, dynamic>>> _fetchMediaEvents() async {
    // Fetch events that have an image_url (potential videos)
    final response = await _supabase
        .from('timeline_events')
        .select()
        .order('order_index', ascending: true); // Assuming order_index or year

    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

    // Filter for YouTube links
    return data.where((event) {
      final url = event['image_url'] as String?;
      if (url == null) return false;
      return url.contains('youtube.com') || url.contains('youtu.be');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Videos",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mediaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final videos = snapshot.data ?? [];

          if (videos.isEmpty) {
            return const Center(child: Text("No videos found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return _buildVideoCard(context, video);
            },
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () {
        // Parse lessons safely
        List<String> lessons = [];
        if (video['lessons'] != null) {
          lessons = List<String>.from(video['lessons']);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoUrl: video['image_url'],
              title: video['title'] ?? 'No Title',
              lessons: lessons,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Pill shape
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side: Icons
            Row(
              children: [
                Icon(Icons.bookmark_border_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                ValueListenableBuilder<List<String>>(
                  valueListenable: FavoritesService().favoriteIds,
                  builder: (context, favIds, _) {
                    final String videoId = video['id'].toString();
                    final isFav = favIds.contains(videoId);
                    return GestureDetector(
                      onTap: () {
                        FavoritesService().toggleFavorite(videoId);
                      },
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border_rounded,
                        color: isFav ? Colors.pinkAccent : AppColors.primary,
                        size: 24,
                      ),
                    );
                  },
                ),
              ],
            ),
            
            // Right Side: Title + Play Icon
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   Expanded(
                    child: Text(
                      video['title'] ?? '',
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Noto Nastaliq Urdu',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
