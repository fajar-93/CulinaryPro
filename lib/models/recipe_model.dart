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

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Extract ingredients and measures
    List<String> ingredientsList = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        final measureStr = (measure != null && measure.toString().trim().isNotEmpty) 
            ? '${measure.toString().trim()} ' 
            : '';
        ingredientsList.add('$measureStr${ingredient.toString().trim()}');
      }
    }

    // Extract instructions
    List<String> instructionsList = [];
    final instructionsStr = json['strInstructions'];
    if (instructionsStr != null) {
      instructionsList = instructionsStr
          .toString()
          .split(RegExp(r'\r\n|\n|\r'))
          .where((line) => line.trim().isNotEmpty)
          .toList();
    }

    // Extract YouTube ID
    String? ytId;
    final ytUrl = json['strYoutube'];
    if (ytUrl != null && ytUrl.toString().isNotEmpty) {
      final uri = Uri.tryParse(ytUrl.toString());
      if (uri != null && uri.queryParameters.containsKey('v')) {
        ytId = uri.queryParameters['v'];
      }
    }

    // Map Category (Fallback to UI categories)
    String rawCategory = json['strCategory']?.toString().toLowerCase() ?? '';
    String mappedCategory = 'makan_siang'; // default
    if (rawCategory == 'dessert') {
      mappedCategory = 'camilan';
    } else if (rawCategory == 'breakfast') {
      mappedCategory = 'sarapan';
    } else if (rawCategory == 'starter' || rawCategory == 'side') {
      mappedCategory = 'camilan';
    }

    return Recipe(
      id: json['idMeal']?.toString() ?? '',
      title: json['strMeal']?.toString() ?? 'Resep Tanpa Nama',
      description: 'Hidangan ${json['strArea'] ?? 'Spesial'} dengan kategori ${json['strCategory'] ?? 'Umum'}.',
      imageUrl: json['strMealThumb']?.toString() ?? '',
      ingredients: ingredientsList,
      instructions: instructionsList,
      durationMinutes: 45, // Default API tidak menyediakan waktu
      difficulty: 'Menengah', // Default
      category: mappedCategory,
      youtubeId: ytId,
    );
  }
}
