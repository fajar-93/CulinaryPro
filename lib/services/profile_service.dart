import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal memuat profil: $e');
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Gagal menyimpan profil: $e');
    }
  }

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    try {
      const cloudName = 'dkta7ujvt';
      const uploadPreset = 'recipe_upload';

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      final data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return data['secure_url'];
      }

      throw Exception(data['error']?['message'] ?? 'Upload gagal');
    } catch (e) {
      throw Exception('Gagal mengunggah foto profil: $e');
    }
  }
}
