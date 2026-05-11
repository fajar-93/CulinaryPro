import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../data/recipe_data.dart';

class RecipeProvider with ChangeNotifier {
  final List<Recipe> _recipes = RecipeData.recipes;
  String _searchQuery = '';

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

  List<Recipe> get favoriteRecipes {
    return _recipes.where((recipe) => recipe.isFavorite).toList();
  }

  void toggleFavorite(String id) {
    final index = _recipes.indexWhere((recipe) => recipe.id == id);
    if (index >= 0) {
      _recipes[index].isFavorite = !_recipes[index].isFavorite;
      notifyListeners();
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
