import 'package:cloud_firestore/cloud_firestore.dart';

class SupportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitSupportMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      await _firestore.collection('support_messages').add({
        'name': name,
        'email': email,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal mengirim pesan: $e');
    }
  }
}
