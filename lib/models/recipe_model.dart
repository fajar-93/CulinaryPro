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
  /// Nilai valid: 'all', 'sarapan', 'makan_siang', 'makan_malam', 'camilan', 'minuman'
  final String category;
  final String? youtubeId;


  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.durationMinutes,
    required this.difficulty,
    this.category = 'makan_siang',
    this.youtubeId,
  });
}
