import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    // Bottom Navigation
    'Beranda': {'id': 'Beranda', 'en': 'Home'},
    'Suka': {'id': 'Suka', 'en': 'Favorites'},
    'Bookmark': {'id': 'Bookmark', 'en': 'Bookmark'},
    'Kategori': {'id': 'Kategori', 'en': 'Category'},
    'Profil': {'id': 'Profil', 'en': 'Profile'},

    // Settings Screen
    'Pengaturan': {'id': 'Pengaturan', 'en': 'Settings'},
    'Akun': {'id': 'Akun', 'en': 'Account'},
    'Lihat info & Edit Profil': {'id': 'Lihat info & Edit Profil', 'en': 'View info & Edit Profile'},
    'Keamanan': {'id': 'Keamanan', 'en': 'Security'},
    'Ubah Password': {'id': 'Ubah Password', 'en': 'Change Password'},
    'Notifikasi': {'id': 'Notifikasi', 'en': 'Notifications'},
    'Aktifkan / Nonaktifkan': {'id': 'Aktifkan / Nonaktifkan', 'en': 'Enable / Disable'},
    'Tema Aplikasi': {'id': 'Tema Aplikasi', 'en': 'App Theme'},
    'Light, Dark, System': {'id': 'Light, Dark, System', 'en': 'Light, Dark, System'},
    'Bahasa': {'id': 'Bahasa', 'en': 'Language'},
    'Indonesia, English': {'id': 'Indonesia, English', 'en': 'Indonesia, English'},
    'Bantuan & FAQ': {'id': 'Bantuan & FAQ', 'en': 'Help & FAQ'},
    'Tentang Aplikasi': {'id': 'Tentang Aplikasi', 'en': 'About App'},
    'LOGOUT': {'id': 'LOGOUT', 'en': 'LOGOUT'},
    'Keluar dari Akun': {'id': 'Keluar dari Akun', 'en': 'Logout Account'},
    'Apakah Anda yakin ingin keluar dari akun?': {'id': 'Apakah Anda yakin ingin keluar dari akun?', 'en': 'Are you sure you want to log out?'},
    'Apakah Anda yakin ingin keluar dari aplikasi?': {'id': 'Apakah Anda yakin ingin keluar dari aplikasi?', 'en': 'Are you sure you want to exit the app?'},
    'Logout': {'id': 'Logout', 'en': 'Logout'},
    'Batal': {'id': 'Batal', 'en': 'Cancel'},
    'Keluar': {'id': 'Keluar', 'en': 'Exit'},
    'Edit Profil': {'id': 'Edit Profil', 'en': 'Edit Profile'},
    'Riwayat Aktivitas': {'id': 'Riwayat Aktivitas', 'en': 'Activity History'},
    'Resep yang Anda unggah': {'id': 'Resep yang Anda unggah', 'en': 'Recipes you uploaded'},

    // Home Screen
    'Mau masak apa hari ini?': {'id': 'Mau masak apa hari ini?', 'en': 'What do you want to cook today?'},
    'Cari resep favoritmu...': {'id': 'Cari resep favoritmu...', 'en': 'Search your favorite recipes...'},
    'Resep Terbaru': {'id': 'Resep Terbaru', 'en': 'Latest Recipes'},
    'Lihat Semua': {'id': 'Lihat Semua', 'en': 'See All'},
    'Belum ada notifikasi baru': {'id': 'Belum ada notifikasi baru', 'en': 'No new notifications'},
    'Semua': {'id': 'Semua', 'en': 'All'},
    'Sarapan': {'id': 'Sarapan', 'en': 'Breakfast'},
    'Makan Siang': {'id': 'Makan Siang', 'en': 'Lunch'},
    'Makan Malam': {'id': 'Makan Malam', 'en': 'Dinner'},
    'Camilan': {'id': 'Camilan', 'en': 'Snacks'},
    'Minuman': {'id': 'Minuman', 'en': 'Drinks'},
    'Resep tidak ditemukan': {'id': 'Resep tidak ditemukan', 'en': 'Recipe not found'},
    'Gagal memuat resep:\n': {'id': 'Gagal memuat resep:\n', 'en': 'Failed to load recipes:\n'},
  };

  static String translate(String key, String langCode) {
    if (_translations.containsKey(key)) {
      return _translations[key]![langCode] ?? key;
    }
    return key;
  }
}

extension TranslationExtension on String {
  String tr(BuildContext context, {bool listen = true}) {
    try {
      final langCode = Provider.of<LanguageProvider>(context, listen: listen).languageCode;
      return AppTranslations.translate(this, langCode);
    } catch (e) {
      return this;
    }
  }
}
