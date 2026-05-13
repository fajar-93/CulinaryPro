import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';

/// Provider untuk mengelola state resep favorit.
/// Menggunakan `Set<String>` untuk menyimpan ID favorit,
/// sehingga otomatis mencegah duplikasi.
class FavoriteProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {};

  /// Mengembalikan salinan set ID favorit (immutable dari luar).
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  /// Mengembalikan apakah sebuah resep sudah difavoritkan.
  bool isFavorite(String id) => _favoriteIds.contains(id);

  /// Mengembalikan jumlah resep favorit.
  int get favoriteCount => _favoriteIds.length;

  /// Toggle favorite: tambah jika belum ada, hapus jika sudah ada.
  /// Duplikasi tidak mungkin terjadi karena menggunakan Set.
  void toggleFavorite(Recipe recipe) {
    if (_favoriteIds.contains(recipe.id)) {
      _favoriteIds.remove(recipe.id);
    } else {
      _favoriteIds.add(recipe.id);
    }
    notifyListeners();
  }

  /// Menambahkan resep ke favorit. Jika sudah ada, tidak melakukan apa-apa.
  void addFavorite(Recipe recipe) {
    if (!_favoriteIds.contains(recipe.id)) {
      _favoriteIds.add(recipe.id);
      notifyListeners();
    }
  }

  /// Menghapus resep dari favorit. Jika tidak ada, tidak melakukan apa-apa.
  void removeFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
      notifyListeners();
    }
  }

  /// Menghapus semua favorit.
  void clearFavorites() {
    if (_favoriteIds.isNotEmpty) {
      _favoriteIds.clear();
      notifyListeners();
    }
  }

  /// Mengembalikan daftar resep favorit dari list resep yang diberikan.
  List<Recipe> getFavoriteRecipes(List<Recipe> allRecipes) {
    return allRecipes
        .where((recipe) => _favoriteIds.contains(recipe.id))
        .toList();
  }
}
