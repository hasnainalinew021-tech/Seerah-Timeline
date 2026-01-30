import 'package:flutter/material.dart';
import 'package:seerah_timeline/constants/app_colors.dart';

class FavouriteTab extends StatelessWidget {
  const FavouriteTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.favorite, size: 72, color: Colors.orange),
              SizedBox(height: 12),
              Text(
                'Favourite',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Your saved events and items will appear here.'),
            ],
          ),
        ),
      ),
    );
  }
}
