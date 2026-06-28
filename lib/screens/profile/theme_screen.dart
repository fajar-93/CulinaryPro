import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Tema Aplikasi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Light Mode'),
                    trailing: themeProvider.themeMode == ThemeMode.light 
                        ? const Icon(Icons.check, color: Colors.orange) 
                        : null,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.light);
                    },
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  ListTile(
                    title: const Text('Dark Mode'),
                    trailing: themeProvider.themeMode == ThemeMode.dark 
                        ? const Icon(Icons.check, color: Colors.orange) 
                        : null,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.dark);
                    },
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  ListTile(
                    title: const Text('System Mode'),
                    trailing: themeProvider.themeMode == ThemeMode.system 
                        ? const Icon(Icons.check, color: Colors.orange) 
                        : null,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.system);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
