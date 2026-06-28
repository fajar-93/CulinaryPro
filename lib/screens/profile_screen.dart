import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import 'help_center_screen.dart';
import 'my_recipes_screen.dart';
import 'profile/settings_screen.dart';
import '../utils/app_translations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<ProfileProvider>().loadProfile(
              user.uid,
              defaultEmail: user.email,
              defaultName: user.displayName,
            );
      }
    });
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'F';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _getChefBadge(int totalSaved) {
    if (totalSaved >= 15) return 'Master Chef 🍳';
    if (totalSaved >= 8) return 'Koki Handal 👨‍🍳';
    if (totalSaved >= 3) return 'Koki Pemula 🥗';
    return 'Koki Amatir 🌾';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Keluar dari Akun'.tr(context, listen: false),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Apakah Anda yakin ingin keluar dari aplikasi CulinaryPro?'.tr(context, listen: false)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal'.tr(context, listen: false), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              Navigator.pop(dialogContext);
              await context.read<AuthProvider>().logout();
              navigator.pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Keluar'.tr(context, listen: false)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Safely get Firebase current user
    User? currentUser;
    try {
      if (Firebase.apps.isNotEmpty) {
        currentUser = FirebaseAuth.instance.currentUser;
      }
    } catch (e) {
      debugPrint('Firebase not available in ProfileScreen: $e');
    }

    final profileProvider = context.watch<ProfileProvider>();
    final userProfile = profileProvider.user;

    final displayName = userProfile?.name ?? currentUser?.displayName ?? 'Foodie User';
    final email = userProfile?.email ?? currentUser?.email ?? 'guest@masakenak.com';

    // Watch stats reaktif
    final favoriteCount = context.watch<FavoriteProvider>().favoriteCount;
    final bookmarkCount = context.watch<BookmarkProvider>().bookmarkCount;
    final totalSaved = favoriteCount + bookmarkCount;
    final chefBadge = _getChefBadge(totalSaved);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Header Gradien dengan Informasi Profil ──────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                          ? [const Color(0xFFE65100), const Color(0xFFFF8F00)] 
                          : [Colors.orange[700]!, Colors.orange[400]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        children: [
                          // Avatar Pengguna
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(30),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: profileProvider.isLoading && userProfile == null
                                ? const CircularProgressIndicator(color: Colors.orange)
                                : userProfile?.profileImage != null && userProfile!.profileImage!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          userProfile.profileImage!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          _getInitials(displayName),
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                          ),
                          const SizedBox(width: 16),
                          // Detail Teks
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(220),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Badge Level Chef
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(50),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    chefBadge,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Edit Profil Button
                          /*IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/edit-profile');
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            tooltip: 'Edit Profil',
                          ),*/
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Bagian Statistik Reaktif ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context, 
                      title: 'Suka'.tr(context), 
                      count: favoriteCount, 
                      icon: Icons.favorite_rounded, 
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context, 
                      title: 'Bookmark'.tr(context), 
                      count: bookmarkCount, 
                      icon: Icons.bookmark_rounded, 
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Pengaturan & Opsi ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline, color: Colors.blue),
                      ),
                      title: Text('Edit Profil'.tr(context), style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings_outlined, color: Colors.orange),
                      ),
                      title: Text('Pengaturan'.tr(context), style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history, color: Colors.green),
                      ),
                      title: Text('Riwayat Aktivitas'.tr(context), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Resep yang Anda unggah'.tr(context)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyRecipesScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper Pembuat Card Stats
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
