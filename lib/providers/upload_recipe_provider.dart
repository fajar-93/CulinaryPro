import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/cloudinary_service.dart';

class UploadRecipeProvider with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Uint8List? _imageBytes;
  File? _imageFile;
  String? _imageName;
  File? _videoFile;
  String? _videoName;
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
  File? get videoFile => _videoFile;
  String? get videoName => _videoName;
  bool get hasVideo => _videoFile != null;

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
        _imageFile = File(pickedFile.path);
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
    _imageFile = null;
    _imageName = null;
    notifyListeners();
  }

  /// Pilih video dari galeri
  Future<void> pickVideo() async {
    try {
      _clearMessages();
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        if (fileSize > 50 * 1024 * 1024) {
          _errorMessage = 'Ukuran video maksimal 50 MB';
          notifyListeners();
          return;
        }

        final ext = pickedFile.path.split('.').last.toLowerCase();
        if (ext != 'mp4' && ext != 'mov' && ext != 'avi') {
          _errorMessage = 'Format video tidak didukung. Gunakan mp4, mov, atau avi.';
          notifyListeners();
          return;
        }

        _videoFile = file;
        _videoName = pickedFile.name;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Gagal memilih video: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Hapus video yang sudah dipilih
  void removeVideo() {
    _videoFile = null;
    _videoName = null;
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
      final cloudinary = CloudinaryService();
      
      // 1. Upload gambar ke Cloudinary
      if (_imageFile == null) {
        throw Exception("File gambar tidak ditemukan");
      }
      final imageUrl = await cloudinary.uploadImage(_imageFile!);
      _uploadProgress = 0.4;
      notifyListeners();

      String? videoUrl;
      // 2. Upload video ke Cloudinary (opsional)
      if (_videoFile != null) {
        videoUrl = await cloudinary.uploadVideo(_videoFile!);
      }

      // 3. Simpan data resep ke Firestore
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
        'videoUrl': videoUrl,
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

  // _uploadToCloudinary removed in favor of CloudinaryService

  /// Reset semua state form
  void resetForm() {
    _imageBytes = null;
    _imageFile = null;
    _imageName = null;
    _videoFile = null;
    _videoName = null;
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
