import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider() {
    // Dengarkan perubahan status auth dari Firebase secara real-time
    _user = _authService.currentUser;
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Register
  Future<bool> register(String email, String name, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signUpWithEmailAndPassword(email, name, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Google Sign In
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signInWithGoogle();
      _setLoading(false);
      return _user != null; // Mengembalikan true jika berhasil login
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Change Password (reauthenticate + update)
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        _errorMessage = 'Pengguna tidak ditemukan. Silakan login ulang.';
        _setLoading(false);
        return false;
      }

      // Reauthenticate with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update to new password
      await user.updatePassword(newPassword);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          _errorMessage = 'Password lama salah. Silakan coba lagi.';
          break;
        case 'weak-password':
          _errorMessage = 'Password baru terlalu lemah. Gunakan minimal 6 karakter.';
          break;
        case 'requires-recent-login':
          _errorMessage = 'Sesi telah kedaluwarsa. Silakan login ulang terlebih dahulu.';
          break;
        default:
          _errorMessage = e.message ?? 'Gagal mengubah password.';
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
    }
  }

  // Helper setter loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Pembersihan error state
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
