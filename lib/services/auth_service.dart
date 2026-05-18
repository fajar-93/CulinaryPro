import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan user yang sedang aktif
  User? get currentUser => _auth.currentUser;

  // Stream status autentikasi untuk melacak login/logout secara real-time
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login dengan Email & Password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi. Silakan coba lagi.');
    }
  }

  // Register Akun Baru dengan Email, Nama, dan Password
  Future<User?> signUpWithEmailAndPassword(
      String email, String name, String password) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        // Update nama profil pengguna agar tersimpan di Firebase Auth
        await user.updateDisplayName(name.trim());
        await user.reload();
      }
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat pendaftaran. Silakan coba lagi.');
    }
  }

  // Logout dari Firebase
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Gagal keluar dari akun. Silakan coba lagi.');
    }
  }

  // Helper untuk menangani pesan error bahasa Indonesia yang ramah pengguna
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('Format email tidak valid.');
      case 'user-disabled':
        return Exception('Akun ini telah dinonaktifkan.');
      case 'user-not-found':
        return Exception('Pengguna dengan email ini tidak ditemukan.');
      case 'wrong-password':
        return Exception('Password yang Anda masukkan salah.');
      case 'email-already-in-use':
        return Exception('Email sudah digunakan oleh akun lain.');
      case 'weak-password':
        return Exception('Password terlalu lemah. Gunakan minimal 6 karakter.');
      case 'operation-not-allowed':
        return Exception('Metode login email & password tidak diaktifkan.');
      case 'invalid-credential':
        return Exception('Email atau password salah.');
      default:
        return Exception(e.message ?? 'Terjadi kesalahan sistem. Coba lagi.');
    }
  }
}
