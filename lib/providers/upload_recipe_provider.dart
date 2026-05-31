import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UploadRecipeProvider with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  Uint8List? get imageBytes => _imageBytes;
  String? get imageName => _imageName;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasImage => _imageBytes != null;

  /// Pilih gambar dari kamera atau galeri
  Future<void> pickImage(ImageSource source) async {
    try {
      _clearMessages();
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _imageBytes = await pickedFile.readAsBytes();
        _imageName = pickedFile.name;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Gagal memilih gambar: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Hapus gambar yang sudah dipilih
  void removeImage() {
    _imageBytes = null;
    notifyListeners();
  }

  /// Upload resep ke Firebase
  Future<bool> uploadRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    required int durationMinutes,
    required String difficulty,
    required String category,
  }) async {
    // Validasi
    if (imageBytes == null) {
      _errorMessage = 'Silakan pilih gambar terlebih dahulu';
      notifyListeners();
      return false;
    }
    if (title.trim().isEmpty) {
      _errorMessage = 'Nama resep tidak boleh kosong';
      notifyListeners();
      return false;
    }
    if (ingredients.isEmpty || ingredients.every((e) => e.trim().isEmpty)) {
      _errorMessage = 'Tambahkan minimal 1 bahan';
      notifyListeners();
      return false;
    }
    if (instructions.isEmpty || instructions.every((e) => e.trim().isEmpty)) {
      _errorMessage = 'Tambahkan minimal 1 langkah memasak';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _uploadProgress = 0.0;
    _clearMessages();
    notifyListeners();

    try {
      // 1. Upload gambar ke Firebase Storage
      final imageUrl = await _uploadToCloudinary(_imageBytes!);

      // 2. Simpan data resep ke Firestore
      _uploadProgress = 0.8;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      final filteredIngredients =
          ingredients.where((e) => e.trim().isNotEmpty).toList();
      final filteredInstructions =
          instructions.where((e) => e.trim().isNotEmpty).toList();

      await _firestore.collection('recipes').add({
        'title': title.trim(),
        'description': description.trim(),
        'imageUrl': imageUrl,
        'ingredients': filteredIngredients,
        'instructions': filteredInstructions,
        'durationMinutes': durationMinutes,
        'difficulty': difficulty,
        'category': category,
        'userId': user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? 'anonymous',
        'userName': user?.displayName ?? 'Anonymous',
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
      });

      _uploadProgress = 1.0;
      _successMessage = 'Resep berhasil diupload! 🎉';
      _isUploading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupload resep: ${e.toString()}';
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return false;
    }
  }

  /// Upload gambar ke Firebase Storage dan return download URL
  Future<String> _uploadToCloudinary(
  Uint8List imageBytes,
  ) async {
    const cloudName = 'dkta7ujvt';
    const uploadPreset = 'recipe_upload';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'recipe.jpg',
      ),
    );

    final response = await request.send();

    final responseData =
        await response.stream.bytesToString();

    final data = jsonDecode(responseData);

    if (response.statusCode == 200) {
      return data['secure_url'];
    } else {
      throw Exception(data['error']['message']);
    }
  }
   

  /// Reset semua state form
  void resetForm() {
    _imageBytes = null;
    _imageName = null;
    _isUploading = false;
    _uploadProgress = 0.0;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
