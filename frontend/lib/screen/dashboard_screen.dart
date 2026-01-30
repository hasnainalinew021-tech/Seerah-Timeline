import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../widget/action_card.dart';
import '../widget/bottom_nav_bar.dart';
import './timeline_screen.dart';
import '../tabs/favourite_tab.dart';
import '../tabs/profile_tab.dart';
import '../tabs/multimedia_tab.dart';
import '../tabs/lesson_tab.dart';
import './chatbot_screen.dart';
import '../constants/app_colors.dart';
import './quiz_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _currentCardIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeContent = SafeArea(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              AppColors.white,
              AppColors.backgroundMint,
              AppColors.backgroundMint,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 0, 16, 30),
          child: Column(
            children: [
              buildNewHeader(context),
              const SizedBox(height: 8),
              buildInfoCards(),
              const SizedBox(height: 10),
              buildEventOfDayCard(),
              const SizedBox(height: 10),
              buildTimelineLessonRow(context),
              const SizedBox(height: 10),
              buildBottomRowSection(context),
            ],
          ),
        ),
      ),
    );

    final pages = [
      homeContent,
      const FavouriteTab(),
      const ProfileTab(),
      const MultimediaTab(),
      const LessonTab(),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: pages),
  
        // ✅ Reusable Bottom Navigation Bar
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  // ---------------- New Header with Logo ----------------
  Widget buildNewHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/images/logo.png', height: 75, width: 70),
        const SizedBox(width: 20),
        Expanded(
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Digital See',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'rah Timeline',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Iconsax.notification,
              color: AppColors.primary,
              size: 24,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // ---------------- Swipeable Info Cards ----------------
  Widget buildInfoCards() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentCardIndex = index;
              });
            },
            children: [
              _buildInfoCard(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Iconsax.book_1,
                title: 'Seerah Journey',
                subtitle: 'Explore the life of Prophet Muhammad (ﷺ)',
                iconBg: Colors.white.withOpacity(0.2),
              ),
              _buildInfoCard(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEA82F), Color(0xFFFBBF24)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Iconsax.crown_1,
                title: 'Daily Wisdom',
                subtitle: 'Learn from the Prophet\'s teachings',
                iconBg: Colors.white.withOpacity(0.2),
              ),
              _buildInfoCard(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Iconsax.star_1,
                title: 'Milestones',
                subtitle: 'Key events in Islamic history',
                iconBg: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildInfoCard({
    required Gradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentCardIndex == index ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: _currentCardIndex == index
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ---------------- Event of the Day Card ----------------
  Widget buildEventOfDayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Event of the Day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'The Birth of Prophet Muhammad (ﷺ)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '12 Rabi\' al-Awwal',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Iconsax.calendar_25,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Timeline & Lessons Row ----------------
  Widget buildTimelineLessonRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ActionCard(
            color: Colors.teal,
            icon: Icons.timeline,
            label: "Timeline",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimelineScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionCard(
            color: Colors.amber.shade700,
            icon: Icons.menu_book,
            label: "Lessons",
            onTap: () {
              setState(() {
                _selectedIndex = 4;
              });
            },
          ),
        ),
      ],
    );
  }

  // ---------------- Bottom Row Section ----------------
  Widget buildBottomRowSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: stacked Multimedia and Favourite
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ActionCard(
                color: Colors.lightBlue.shade800,
                icon: Icons.play_circle_fill,
                label: "Mulimedia",
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),
              SizedBox(height: 10),
              ActionCard(
                color: Colors.orange.shade700,
                icon: Icons.favorite,
                label: "Favourite",
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Right: stacked Quiz and AI Chatbot
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ActionCard(
                color: Colors.green.shade700,
                icon: Icons.quiz,
                label: "Quiz",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              ActionCard(
                color: Colors.purple.shade700,
                icon: Icons.chat_bubble_outline,
                label: "AI Chat",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatbotScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // (Favourite card is now integrated into the bottom row stack)
}
