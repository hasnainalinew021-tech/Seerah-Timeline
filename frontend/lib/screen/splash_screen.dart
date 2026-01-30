import 'dart:async';
import 'package:flutter/material.dart';
import 'package:seerah_timeline/constants/app_colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:seerah_timeline/auth/auth_gate.dart';
import 'package:seerah_timeline/screen/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthGate()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8FFF5), Color(0xFFD8F5EB)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 50,
                      color: Colors.teal.shade700,
                    ),
                    Positioned(
                      top: 20,
                      left: 28,
                      child: Icon(
                        Icons.nights_stay_rounded,
                        size: 24,
                        color: Colors.orange.shade400,
                      ),
                    ),
                    Positioned(
                      bottom: 25,
                      right: 28,
                      child: Icon(
                        Iconsax.clock,
                        size: 20,
                        color: Colors.orange.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 📘 App Name
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Digital ",
                      style: TextStyle(
                        color: Colors.teal.shade800,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    TextSpan(
                      text: "Seerah",
                      style: TextStyle(
                        color: Colors.orange.shade600,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 📖 Subtitle
              Text(
                "Journey Through the Seerah",
                style: TextStyle(
                  color: Colors.teal.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 20),

              // Decorative line
              Container(width: 100, height: 1, color: Colors.teal.shade300),

              const SizedBox(height: 20),

              // Page indicator (3 dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(true, Colors.orange.shade500),
                  const SizedBox(width: 6),
                  _buildDot(false, Colors.teal.shade400),
                  const SizedBox(width: 6),
                  _buildDot(false, Colors.teal.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool active, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 10 : 8,
      height: active ? 10 : 8,
      decoration: BoxDecoration(
        color: color.withOpacity(active ? 1.0 : 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
