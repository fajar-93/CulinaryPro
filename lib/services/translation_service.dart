import 'package:translator/translator.dart';
import '../models/recipe_model.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  // Menerjemahkan seluruh resep (judul, deskripsi, bahan-bahan, instruksi) secara paralel
  Future<Recipe> translateRecipe(Recipe recipe) async {
    try {
      // 1. Definisikan pemanggilan masa depan untuk judul dan deskripsi
      final titleFuture = _translator.translate(recipe.title, from: 'en', to: 'id');
      final descFuture = _translator.translate(recipe.description, from: 'en', to: 'id');

      // 2. Menerjemahkan daftar bahan-bahan secara paralel
      final ingredientFutures = recipe.ingredients
          .map((ing) => _translator.translate(ing, from: 'en', to: 'id'))
          .toList();

      // 3. Menerjemahkan langkah memasak secara paralel
      final instructionFutures = recipe.instructions
          .map((ins) => _translator.translate(ins, from: 'en', to: 'id'))
          .toList();

      // 4. Jalankan seluruh proses translasi secara paralel dengan Future.wait
      final results = await Future.wait([
        titleFuture,
        descFuture,
        Future.wait(ingredientFutures),
        Future.wait(instructionFutures),
      ]);

      final titleTr = results[0] as Translation;
      final descTr = results[1] as Translation;
      final ingredientsTr = results[2] as List<Translation>;
      final instructionsTr = results[3] as List<Translation>;

      // Menerjemahkan tingkat kesulitan
      String difficultyId = recipe.difficulty;
      if (difficultyId.toLowerCase() == 'easy') {
        difficultyId = 'Mudah';
      } else if (difficultyId.toLowerCase() == 'medium' || difficultyId.toLowerCase() == 'menengah') {
        difficultyId = 'Sedang';
      } else if (difficultyId.toLowerCase() == 'hard') {
        difficultyId = 'Sulit';
      }

      return Recipe(
        id: recipe.id,
        title: titleTr.text,
        description: descTr.text,
        imageUrl: recipe.imageUrl,
        ingredients: ingredientsTr.map((t) => t.text).toList(),
        instructions: instructionsTr.map((t) => t.text).toList(),
        durationMinutes: recipe.durationMinutes,
        difficulty: difficultyId,
        category: recipe.category,
        youtubeId: recipe.youtubeId,
      );
    } catch (e) {
      throw Exception('Gagal menerjemahkan resep. Silakan periksa koneksi internet Anda.');
    }
  }
}
