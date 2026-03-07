import 'package:flutter/material.dart';
import 'package:seerah_timeline/widget/app_search_bar.dart';
import 'package:seerah_timeline/widget/custom_appbar.dart';
import '../constants/app_colors.dart';
class ShumailScreen extends StatefulWidget {
    const ShumailScreen({super.key});
    
    @override
    State<ShumailScreen> createState() => _ShumailScreenState();
}

class _ShumailScreenState extends State<ShumailScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController =TextEditingController();

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CustomAppbar(titleOne: ' Shumail of ', titleTwo: 'Rasulullah ﷺ'),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            children: [
              AppSearchBar(
              hintText: "Search Shumail or any Dua 🤲🏻", 
              onChanged: _onSearchChanged, 
              controller: _searchController
              )
            ],
          ),
        )
    );
    }
}