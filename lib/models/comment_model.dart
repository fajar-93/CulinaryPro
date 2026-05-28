import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String recipeId;
  final String userId;
  final String userName;
  final String text;
  final double rating;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      recipeId: data['recipeId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'User',
      text: data['text'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
