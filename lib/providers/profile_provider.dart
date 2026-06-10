import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> loadProfile(
    String uid, {
    String? defaultEmail,
    String? defaultName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userProfile = await _fetchUserProfile(uid);
      if (userProfile != null) {
        _user = userProfile;
      } else {
        // Jika data tidak ada di Firestore (user baru login via email/Google tapi belum tersimpan profile utuhnya)
        _user = UserModel(
          uid: uid,
          name: defaultName ?? '',
          username: '',
          email: defaultEmail ?? '',
          phone: '',
          address: '',
          bio: '',
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> _fetchUserProfile(String uid) async {
    final dynamic service = _profileService;

    try {
      return await service.getProfile(uid);
    } on NoSuchMethodError {
      // ignore
    }

    try {
      return await service.getUserProfile(uid);
    } on NoSuchMethodError {
      // ignore
    }

    try {
      return await service.fetchProfile(uid);
    } on NoSuchMethodError {
      throw UnsupportedError(
        'ProfileService must implement getProfile, getUserProfile, or fetchProfile.',
      );
    }
  }

  Future<void> _updateUserProfile(UserModel updatedUser) async {
    final dynamic service = _profileService;

    try {
      return await service.updateProfile(updatedUser);
    } on NoSuchMethodError {
      // ignore
    }

    try {
      return await service.updateUserProfile(updatedUser);
    } on NoSuchMethodError {
      throw UnsupportedError(
        'ProfileService must implement updateProfile or updateUserProfile.',
      );
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _updateUserProfile(updatedUser);
      _user = updatedUser;
      _successMessage = 'Profil berhasil diperbarui';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeProfileImage(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Update Firestore: set profileImage ke null / string kosong
      final updatedUser = _user!.copyWith(profileImage: '');
      await _updateUserProfile(updatedUser);
      _user = updatedUser;
      _successMessage = 'Foto profil berhasil dihapus';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final downloadUrl = await _profileService.uploadProfileImage(
        uid,
        imageFile,
      );

      // Jika user sudah ada, otomatis update state lokal (jangan panggil updateUserProfile di sini agar bisa disimpan berbarengan)
      if (_user != null) {
        _user = _user!.copyWith(profileImage: downloadUrl);
      }

      _isLoading = false;
      notifyListeners();
      return downloadUrl;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
