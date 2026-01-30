import 'package:flutter/material.dart';
import 'package:seerah_timeline/constants/app_colors.dart';

class MultimediaTab extends StatelessWidget {
  const MultimediaTab({super.key});

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
              Icon(Icons.play_circle_fill, size: 72, color: Colors.blue),
              SizedBox(height: 12),
              Text(
                'Multimedia',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Videos, audio and other media.'),
            ],
          ),
        ),
      ),
    );
  }
}
