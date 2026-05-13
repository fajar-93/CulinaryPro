import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../data/category_data.dart';

/// Provider untuk mengelola state kategori yang dipilih.
class CategoryProvider with ChangeNotifier {
  String _selectedCategoryId = 'all';

  /// ID kategori yang sedang aktif.
  String get selectedCategoryId => _selectedCategoryId;

  /// Seluruh daftar kategori.
  List<RecipeCategory> get categories => CategoryData.categories;

  /// Kategori yang sedang aktif dipilih.
  RecipeCategory get selectedCategory => CategoryData.categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
      );

  /// Mengubah kategori yang aktif.
  void selectCategory(String id) {
    if (_selectedCategoryId != id) {
      _selectedCategoryId = id;
      notifyListeners();
    }
  }

  /// Reset ke kategori "Semua".
  void resetCategory() {
    selectCategory('all');
  }
}
