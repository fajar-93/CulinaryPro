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
      id: 'sarapan',
      name: 'Sarapan',
      icon: Icons.breakfast_dining_rounded,
      color: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
    ),
    RecipeCategory(
      id: 'makan_siang',
      name: 'Makan Siang',
      icon: Icons.lunch_dining_rounded,
      color: Color(0xFFFCE4EC),
      iconColor: Color(0xFFC62828),
    ),
    RecipeCategory(
      id: 'makan_malam',
      name: 'Makan Malam',
      icon: Icons.dinner_dining_rounded,
      color: Color(0xFFE3F2FD),
      iconColor: Color(0xFF1565C0),
    ),
    RecipeCategory(
      id: 'camilan',
      name: 'Camilan',
      icon: Icons.fastfood_rounded,
      color: Color(0xFFFFF8E1),
      iconColor: Color(0xFFF57F17),
    ),
    RecipeCategory(
      id: 'minuman',
      name: 'Minuman',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFFF3E5F5),
      iconColor: Color(0xFF6A1B9A),
    ),
  ];
}
