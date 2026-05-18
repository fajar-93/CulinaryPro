import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';

class RecipeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Recipe> _recipes = [];
  String _searchQuery = '';
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Seluruh daftar resep (hasil API)
  List<Recipe> get allRecipes => List.unmodifiable(_recipes);

  /// Daftar resep (API sudah melakukan filter pencarian)
  List<Recipe> get recipes => List.unmodifiable(_recipes);

  /// Mengambil data awal
  Future<void> fetchInitialRecipes() async {
    if (_recipes.isEmpty && !_isLoading) {
      await _fetchFromApi('');
    }
  }

  /// Memperbarui query dan mengambil ulang data dari API
  Future<void> updateSearchQuery(String query) async {
    if (_searchQuery == query) return; // hindari duplicate request
    _searchQuery = query;
    await _fetchFromApi(query);
  }

  Future<void> _fetchFromApi(String query) async {
    _isLoading = true;
    _errorMessage = null;
    // Debounce manual sederhana bisa ditambahkan jika perlu
    notifyListeners();

    try {
      final results = await _apiService.searchRecipes(query);
      _recipes = results;
    } catch (e) {
      _errorMessage = e.toString();
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Recipe findById(String id) {
    return _recipes.firstWhere(
      (recipe) => recipe.id == id,
      orElse: () => throw Exception('Recipe with ID $id not found in local cache')
    );
  }
}
