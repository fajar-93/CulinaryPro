import 'package:flutter/material.dart';

/// Model data yang merepresentasikan satu kategori resep.
class RecipeCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const RecipeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
}
