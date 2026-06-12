import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mengambil semua resep dari Firestore diurutkan terbaru.
  Future<List<Recipe>> fetchAllRecipes() async {
    try {
      final snapshot = await _firestore
          .collection('recipes')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Recipe.fromFirestore(doc.id, doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Gagal memuat resep: $e');
    }
  }

  /// Mengambil resep milik user tertentu.
  Future<List<Recipe>> fetchMyRecipes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('recipes')
          .where('userId', isEqualTo: userId)
          .get();

      final docs = snapshot.docs.toList();
      
      // Sort locally to avoid needing a Firestore composite index
      docs.sort((a, b) {
        final dataA = a.data();
        final dataB = b.data();
        final aTime = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime); // descending
      });

      return docs.map((doc) {
        return Recipe.fromFirestore(doc.id, doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Gagal memuat resep Anda: $e');
    }
  }

  /// Menghapus resep dari Firestore.
  /// Gambar Cloudinary dibiarkan karena membutuhkan akses server-side
  /// untuk menghapus dengan aman (API Secret).
  Future<void> deleteRecipe(String recipeId, String imageUrl) async {
    try {
      // 1. Hapus dokumen dari Firestore
      await _firestore.collection('recipes').doc(recipeId).delete();

      // (Gambar Cloudinary tidak dihapus dari client-side untuk menghindari error keamanan)
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw Exception('Anda tidak memiliki izin untuk menghapus resep ini.');
        case 'not-found':
          throw Exception('Resep tidak ditemukan atau sudah dihapus.');
        case 'unavailable':
          throw Exception(
              'Layanan tidak tersedia. Periksa koneksi internet Anda.');
        default:
          throw Exception('Gagal menghapus resep: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
