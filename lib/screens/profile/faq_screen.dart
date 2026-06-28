import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final faqData = [
      {
        'question': 'Bagaimana cara mengubah password?',
        'answer': 'Buka Pengaturan > Keamanan > Lupa Password, lalu ikuti instruksi yang dikirimkan ke email Anda untuk mengubah password.',
      },
      {
        'question': 'Bagaimana cara menyimpan resep favorit?',
        'answer': 'Anda dapat menekan ikon "Hati" atau "Suka" pada resep yang Anda lihat untuk menyimpannya ke daftar resep favorit Anda.',
      },
      {
        'question': 'Bagaimana cara menghubungi admin?',
        'answer': 'Anda dapat menghubungi kami melalui email di support@culinarypro.com atau melalui Pusat Bantuan di halaman Pengaturan.',
      },
      {
        'question': 'Apakah saya bisa mengunggah resep saya sendiri?',
        'answer': 'Tentu! Anda bisa menggunakan tombol "+" atau menu "Upload Resep" untuk membagikan resep Anda kepada komunitas.',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Bantuan & FAQ'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          final item = faqData[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: Colors.orange,
                  collapsedIconColor: Colors.grey,
                  title: Text(
                    item['question']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        item['answer']!,
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
