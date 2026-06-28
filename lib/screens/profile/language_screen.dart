import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Bahasa'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Indonesia'),
                    trailing: languageProvider.languageCode == 'id' 
                        ? const Icon(Icons.check, color: Colors.orange) 
                        : null,
                    onTap: () {
                      languageProvider.setLanguage('id');
                    },
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  ListTile(
                    title: const Text('English'),
                    trailing: languageProvider.languageCode == 'en' 
                        ? const Icon(Icons.check, color: Colors.orange) 
                        : null,
                    onTap: () {
                      languageProvider.setLanguage('en');
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
