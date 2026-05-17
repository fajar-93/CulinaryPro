class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final int durationMinutes;
  final String difficulty;

  /// ID kategori resep — harus sesuai dengan `RecipeCategory.id`
  /// di `CategoryData.categories`.
  /// Nilai valid: 'all', 'main_course', 'dessert', 'beverage', 'soup', 'snack'
  final String category;


  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.durationMinutes,
    required this.difficulty,
    this.category = 'main_course',
  });
}
