import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notifProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_outlined, color: Colors.orange),
                ),
                title: const Text(
                  'Izinkan Notifikasi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Terima pembaruan dan rekomendasi resep terbaru.'),
                trailing: Switch(
                  value: notifProvider.isNotificationEnabled,
                  onChanged: (value) => notifProvider.toggleNotification(value),
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.orange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
