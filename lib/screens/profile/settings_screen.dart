import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/custom_dialog.dart';
import 'account_screen.dart';
import 'security_screen.dart';
import 'notification_screen.dart';
import 'theme_screen.dart';
import 'language_screen.dart';
import 'faq_screen.dart';
import 'about_screen.dart';
import '../../utils/app_translations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        title: 'Keluar dari Akun'.tr(context, listen: false),
        content: 'Apakah Anda yakin ingin keluar dari akun?'.tr(context, listen: false),
        confirmText: 'Logout'.tr(context, listen: false),
        confirmColor: Colors.red,
        onCancel: () => Navigator.pop(dialogContext),
        onConfirm: () async {
          final navigator = Navigator.of(context);
          Navigator.pop(dialogContext);
          await context.read<AuthProvider>().logout();
          navigator.pushNamedAndRemoveUntil('/login', (route) => false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Pengaturan'.tr(context)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.person_outline,
                      iconColor: Colors.blue,
                      title: 'Akun'.tr(context),
                      subtitle: 'Lihat info & Edit Profil'.tr(context),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen())),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    SettingsTile(
                      icon: Icons.security_outlined,
                      iconColor: Colors.green,
                      title: 'Keamanan'.tr(context),
                      subtitle: 'Ubah Password'.tr(context),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen())),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    SettingsTile(
                      icon: Icons.notifications_none,
                      iconColor: Colors.orange,
                      title: 'Notifikasi'.tr(context),
                      subtitle: 'Aktifkan / Nonaktifkan'.tr(context),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    SettingsTile(
                      icon: Icons.palette_outlined,
                      iconColor: Colors.purple,
                      title: 'Tema Aplikasi'.tr(context),
                      subtitle: 'Light, Dark, System'.tr(context),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen())),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    SettingsTile(
                      icon: Icons.language,
                      iconColor: Colors.teal,
                      title: 'Bahasa'.tr(context),
                      subtitle: 'Indonesia, English'.tr(context),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen())),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.help_outline,
                      iconColor: Colors.cyan,
                      title: 'Bantuan & FAQ'.tr(context),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQScreen())),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    SettingsTile(
                      icon: Icons.info_outline,
                      iconColor: Colors.indigo,
                      title: 'Tentang Aplikasi'.tr(context),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    'LOGOUT'.tr(context),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50] ?? const Color(0xFFFFEBEE),
                    foregroundColor: Colors.red[700] ?? Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red[200] ?? Colors.redAccent),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
