import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../data/recipe_data.dart';

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
    notifyListeners();

    try {
      // 1. Ambil resep lokal yang cocok dengan query
      final localFiltered = RecipeData.recipes.where((recipe) {
        final titleLower = recipe.title.toLowerCase();
        final queryLower = query.toLowerCase();
        return titleLower.contains(queryLower);
      }).toList();

      // 2. Ambil resep dari API online
      final apiResults = await _apiService.searchRecipes(query);

      // 3. Gabungkan keduanya secara cerdas (menghindari ID ganda)
      final merged = [...localFiltered];
      for (final apiRecipe in apiResults) {
        if (!merged.any((r) => r.id == apiRecipe.id)) {
          merged.add(apiRecipe);
        }
      }

      _recipes = merged;
    } catch (e) {
      // Offline fallback: jika API gagal (misal tidak ada internet), tampilkan data lokal saja
      debugPrint('API Fetch failed, fallback to local data: $e');
      final localFiltered = RecipeData.recipes.where((recipe) {
        final titleLower = recipe.title.toLowerCase();
        final queryLower = query.toLowerCase();
        return titleLower.contains(queryLower);
      }).toList();

      _recipes = localFiltered;

      // Jika data lokal pun kosong untuk kata kunci tersebut, tampilkan pesan error
      if (_recipes.isEmpty) {
        _errorMessage = 'Gagal memuat resep dari internet. Silakan periksa koneksi Anda.';
      }
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
