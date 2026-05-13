import 'package:flutter/material.dart';
import '../models/category_model.dart';

/// Daftar kategori resep yang tersedia di aplikasi.
class CategoryData {
  static const List<RecipeCategory> categories = [
    RecipeCategory(
      id: 'all',
      name: 'Semua',
      icon: Icons.restaurant_menu_rounded,
      color: Color(0xFFFFF3E0),
      iconColor: Color(0xFFFF6F00),
    ),
    RecipeCategory(
      id: 'main_course',
      name: 'Makanan Utama',
      icon: Icons.set_meal_rounded,
      color: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
    ),
    RecipeCategory(
      id: 'dessert',
      name: 'Dessert',
      icon: Icons.cake_rounded,
      color: Color(0xFFFCE4EC),
      iconColor: Color(0xFFC62828),
    ),
    RecipeCategory(
      id: 'beverage',
      name: 'Minuman',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFFE3F2FD),
      iconColor: Color(0xFF1565C0),
    ),
    RecipeCategory(
      id: 'soup',
      name: 'Sup',
      icon: Icons.soup_kitchen_rounded,
      color: Color(0xFFF3E5F5),
      iconColor: Color(0xFF6A1B9A),
    ),
    RecipeCategory(
      id: 'snack',
      name: 'Snack',
      icon: Icons.fastfood_rounded,
      color: Color(0xFFFFF8E1),
      iconColor: Color(0xFFF57F17),
    ),
  ];
}
