import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

class BookmarkProvider with ChangeNotifier {
  static const String _bookmarkKey = 'bookmarked_recipes';
  final Set<String> _bookmarkIds = {};

  Set<String> get bookmarkIds => Set.unmodifiable(_bookmarkIds);

  bool isBookmarked(String id) => _bookmarkIds.contains(id);

  int get bookmarkCount => _bookmarkIds.length;

  BookmarkProvider() {
    _loadBookmarks();
  }

  void toggleBookmark(Recipe recipe) {
    if (_bookmarkIds.contains(recipe.id)) {
      _bookmarkIds.remove(recipe.id);
    } else {
      _bookmarkIds.add(recipe.id);
    }
    _saveBookmarks();
    notifyListeners();
  }

  void clearBookmarks() {
    if (_bookmarkIds.isNotEmpty) {
      _bookmarkIds.clear();
      _saveBookmarks();
      notifyListeners();
    }
  }

  List<Recipe> getBookmarkedRecipes(List<Recipe> allRecipes) {
    return allRecipes
        .where((recipe) => _bookmarkIds.contains(recipe.id))
        .toList();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedBookmarks = prefs.getStringList(_bookmarkKey);
    if (savedBookmarks != null) {
      _bookmarkIds.addAll(savedBookmarks);
      notifyListeners();
    }
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarkKey, _bookmarkIds.toList());
  }
}
