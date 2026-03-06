import 'package:flutter/material.dart';
import 'package:seerah_timeline/widget/custom_appbar.dart';
import '../constants/app_colors.dart';
class ShumailScreen extends StatefulWidget {
    const ShumailScreen({super.key});
    
    @override
    State<ShumailScreen> createState() => _ShumailScreenState();
}

class _ShumailScreenState extends State<ShumailScreen> {
    @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CustomAppbar(titleOne: ' Shumail of ', titleTwo: 'Rasulullah ﷺ'),
        body: Center(
            child: Text('Shumail Screen'),
        ),
    );
    }
}