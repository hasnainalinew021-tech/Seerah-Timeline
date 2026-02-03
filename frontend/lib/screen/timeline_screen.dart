import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_colors.dart';
import '../widget/timeline_card.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedCategory = 'All'; // Default selected tab
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await supabase
          .from('timeline_events')
          .select()
          .order('order_index', ascending: true);

      setState(() {
        events = List<Map<String, dynamic>>.from(response);
        _filterEvents();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load events: $e';
        isLoading = false;
      });
    }
  }

  void _filterEvents() {
    setState(() {
      filteredEvents = events.where((event) {
        // 1. Category Filter
        final matchesCategory = selectedCategory == 'All' || event['category'] == selectedCategory;

        // 2. Search Filter
        final query = _searchQuery.toLowerCase().trim();
        final title = (event['title'] ?? '').toString().toLowerCase();
        final description = (event['short_description'] ?? '').toString().toLowerCase();
        final fullDesc = (event['full_description'] ?? '').toString().toLowerCase();
        final year = (event['year'] ?? '').toString().toLowerCase();

        final matchesSearch = query.isEmpty ||
            title.contains(query) ||
            description.contains(query) ||
            fullDesc.contains(query) ||
            year.contains(query);

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      _filterEvents();
    });
  }
  
  void _onSearchQueryChanged(String query) {
     _searchQuery = query;
     _filterEvents();
  }

  // 🔹 Builds the timeline layout with line, circle, and card
  Widget buildTimelineItem(BuildContext context, Widget card) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // 🟢 Vertical Line
        Positioned(
          left: 22,
          top: 0,
          bottom: 0,
          child: Container(width: 3, color: Colors.teal.shade300),
        ),

        // ⚪ Circle Marker
        Positioned(
          left: 15,
          top: 25,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.teal.shade400, width: 2),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // 📘 Timeline Card
        Padding(padding: const EdgeInsets.only(left: 40), child: card),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "Seerah ",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "Timeline",
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              onChanged: _onSearchQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search Events, Places...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(
                    color: AppColors.backgroundMint,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(
                    color: AppColors.backgroundMint,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Filter Buttons Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton("All", selectedCategory == "All"),
                  _buildFilterButton(
                    "Pre-Prophethood",
                    selectedCategory == "Pre-Prophethood",
                  ),
                  _buildFilterButton("Makkah", selectedCategory == "Makkah"),
                  _buildFilterButton("Madina", selectedCategory == "Madina"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Timeline Cards with Line and Circles
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchEvents,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : filteredEvents.isEmpty
                  ? const Center(child: Text('No events found'))
                  : ListView.builder(
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        
                        // Parse JSON/List columns safely
                        // Supabase Dart returns text[] as List<dynamic> usually
                        final refs = (event['references'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                        final less = (event['lessons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

                        return buildTimelineItem(
                          context,
                          TimelineCard(
                            id: event['id'].toString(), 
                            year: event['year'] ?? '',
                            title: event['title'] ?? 'Untitled',
                            description: event['short_description'] ?? '',
                            imageUrl: event['image_url'],
                            fullDescription: event['full_description'],
                            category: event['category'],
                            references: refs,
                            lessons: less,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Filter Button Builder
  Widget _buildFilterButton(String text, bool selected) {
    return GestureDetector(
      onTap: () => _onCategorySelected(text),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
