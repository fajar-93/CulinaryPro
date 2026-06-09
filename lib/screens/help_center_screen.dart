import 'package:flutter/material.dart';
import '../widgets/faq_item.dart';
import '../services/support_service.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  final SupportService _supportService = SupportService();
  bool _isLoading = false;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Bagaimana cara menyimpan resep favorit?',
      'answer': 'Anda dapat menekan ikon hati (love) pada halaman detail resep atau di card resep untuk menyimpannya ke daftar favorit Anda.',
    },
    {
      'question': 'Bagaimana cara mengubah password?',
      'answer': 'Fitur ubah password dapat diakses melalui menu Pengaturan > Keamanan > Ubah Password. Anda akan menerima email reset password.',
    },
    {
      'question': 'Bagaimana cara mengaktifkan dark mode?',
      'answer': 'Buka halaman Profil, kemudian tap toggle switch pada opsi "Mode Gelap" untuk beralih antara tema terang dan gelap.',
    },
    {
      'question': 'Bagaimana cara mengunggah resep?',
      'answer': 'Saat ini fitur unggah resep pengguna sedang dalam pengembangan. Silakan tunggu update aplikasi selanjutnya.',
    },
    {
      'question': 'Bagaimana cara menghubungi admin?',
      'answer': 'Anda dapat menghubungi kami melalui formulir "Kirim Pertanyaan" di halaman ini atau melalui kontak WhatsApp yang tersedia.',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitMessage() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await _supportService.submitSupportMessage(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          message: _messageController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesan berhasil dikirim. Kami akan segera membalasnya.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _formKey.currentState!.reset();
          _nameController.clear();
          _emailController.clear();
          _messageController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim pesan: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Pusat Bantuan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 50 : 10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      size: 48,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Halo, ada yang bisa kami bantu?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Temukan jawaban atas pertanyaan Anda atau hubungi tim support kami.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FAQ Section
                  const Text(
                    'FAQ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._faqs.map((faq) => FaqItem(
                        question: faq['question']!,
                        answer: faq['answer']!,
                      )),
                  
                  const SizedBox(height: 32),

                  // Contact Us Section
                  const Text(
                    'Hubungi Kami',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    context: context,
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: 'support@culinarypro.com',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    context: context,
                    icon: Icons.chat_bubble_outline,
                    title: 'WhatsApp',
                    subtitle: '+62 877-4763-3246',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    context: context,
                    icon: Icons.access_time,
                    title: 'Jam Operasional',
                    subtitle: '08.00 - 17.00 WIB (Senin - Jumat)',
                    color: Colors.purple,
                  ),

                  const SizedBox(height: 32),

                  // Contact Form Section
                  const Text(
                    'Kirim Pertanyaan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? Colors.white12 : Colors.grey[200]!,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              label: 'Nama Lengkap',
                              icon: Icons.person_outline,
                              validator: (value) => value?.isEmpty ?? true ? 'Nama wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _messageController,
                              label: 'Pesan',
                              icon: Icons.message_outlined,
                              maxLines: 4,
                              validator: (value) => value?.isEmpty ?? true ? 'Pesan wajib diisi' : null,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitMessage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Kirim Pesan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon) : Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Icon(icon),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C2C)
            : Colors.grey[50],
      ),
    );
  }
}
