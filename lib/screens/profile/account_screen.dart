import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/profile_provider.dart';
import '../edit_profile_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();
    final userProfile = profileProvider.user;
    final authUser = FirebaseAuth.instance.currentUser;

    final displayName = userProfile?.name ?? authUser?.displayName ?? 'Pengguna';
    final username = userProfile?.username ?? '';
    final email = userProfile?.email ?? authUser?.email ?? 'Tidak ada email';
    final phone = userProfile?.phone ?? 'Belum ditambahkan';
    
    String joinDateStr = 'Tidak diketahui';
    if (authUser?.metadata.creationTime != null) {
      joinDateStr = DateFormat('dd MMMM yyyy').format(authUser!.metadata.creationTime!);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  border: Border.all(color: Colors.orange, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withAlpha(50),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: userProfile?.profileImage != null && userProfile!.profileImage!.isNotEmpty
                      ? Image.network(
                          userProfile.profileImage!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            _getInitials(displayName),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Nama Lengkap (Title)
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (username.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '@$username',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            
            const SizedBox(height: 32),

            // Informasi Akun Card
            Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.email_outlined,
                      iconColor: Colors.blue,
                      title: 'Email',
                      value: email,
                    ),
                    const Divider(indent: 72, height: 1),
                    _buildInfoTile(
                      icon: Icons.phone_outlined,
                      iconColor: Colors.green,
                      title: 'Nomor Telepon',
                      value: phone.isEmpty ? 'Belum ditambahkan' : phone,
                    ),
                    const Divider(indent: 72, height: 1),
                    _buildInfoTile(
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.purple,
                      title: 'Tanggal Bergabung',
                      value: joinDateStr,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Tombol Edit Besar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text(
                  'UBAH INFORMASI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(30),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

