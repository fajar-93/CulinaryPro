import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan stream komentar untuk resep tertentu secara real-time
  Stream<List<Comment>> getCommentsStream(String recipeId) {
    return _firestore
        .collection('comments')
        .where('recipeId', isEqualTo: recipeId)
        .snapshots()
        .map((snapshot) {
          final comments = snapshot.docs
              .map((doc) => Comment.fromFirestore(doc))
              .toList();
          // Sort di sisi client agar tidak perlu composite index di Firestore
          comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return comments;
        });
  }

  // Menambahkan komentar baru
  Future<void> addComment({
    required String recipeId,
    required String userId,
    required String userName,
    required String text,
    required double rating,
  }) async {
    try {
      final newComment = Comment(
        id: '', // ID akan digenerate oleh Firestore
        recipeId: recipeId,
        userId: userId,
        userName: userName,
        text: text,
        rating: rating,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('comments').add(newComment.toMap());
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }
}
