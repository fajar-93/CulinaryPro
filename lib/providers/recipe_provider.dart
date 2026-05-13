import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../data/recipe_data.dart';

class RecipeProvider with ChangeNotifier {
  final List<Recipe> _recipes = RecipeData.recipes;
  String _searchQuery = '';

  /// Seluruh daftar resep tanpa filter — dipakai oleh FavoriteProvider.
  List<Recipe> get allRecipes => List.unmodifiable(_recipes);

  /// Daftar resep yang sudah difilter berdasarkan query pencarian.
  List<Recipe> get recipes {
    if (_searchQuery.isEmpty) {
      return [..._recipes];
    } else {
      return _recipes
          .where((recipe) =>
              recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Recipe findById(String id) {
    return _recipes.firstWhere((recipe) => recipe.id == id);
  }
}
