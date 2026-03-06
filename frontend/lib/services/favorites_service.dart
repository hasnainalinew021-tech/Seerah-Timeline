import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;

  FavoritesService._internal();

  final ValueNotifier<List<String>> favoriteIds = ValueNotifier([]);
  static const String _prefsKey = 'favorite_event_ids';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList(_prefsKey);
    if (stored != null) {
      favoriteIds.value = stored;
    }
  }

  Future<void> toggleFavorite(String id) async {
    final List<String> currentList = List.from(favoriteIds.value);
    if (currentList.contains(id)) {
      currentList.remove(id);
    } else {
      currentList.add(id);
    }
    
    favoriteIds.value = currentList;
    
    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, currentList);
  }

  bool isFavorite(String id) {
    return favoriteIds.value.contains(id);
  }
}
