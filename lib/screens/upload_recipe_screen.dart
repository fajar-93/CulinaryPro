import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/upload_recipe_provider.dart';
import '../providers/recipe_provider.dart';
class UploadRecipeScreen extends StatefulWidget {
  const UploadRecipeScreen({super.key});

  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  // Dynamic lists for ingredients & instructions
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _instructionControllers = [
    TextEditingController()
  ];

  String _selectedDifficulty = 'Menengah';
  String _selectedCategory = 'makan_siang';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _difficulties = ['Mudah', 'Menengah', 'Sulit'];
  final Map<String, String> _categories = {
    'sarapan': 'Sarapan',
    'makan_siang': 'Makan Siang',
    'makan_malam': 'Makan Malam',
    'camilan': 'Camilan',
    'minuman': 'Minuman',
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    for (final c in _ingredientControllers) {
      c.dispose();
    }
    for (final c in _instructionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstruction(int index) {
    if (_instructionControllers.length > 1) {
      setState(() {
        _instructionControllers[index].dispose();
        _instructionControllers.removeAt(index);
      });
    }
  }

  void _showImageSourceSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih Sumber Gambar',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        context
                            .read<UploadRecipeProvider>()
                            .pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        context
                            .read<UploadRecipeProvider>()
                            .pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UploadRecipeProvider>();
    if (!provider.hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Silakan pilih gambar terlebih dahulu'),
            ],
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final ingredients =
        _ingredientControllers.map((c) => c.text.trim()).toList();
    final instructions =
        _instructionControllers.map((c) => c.text.trim()).toList();

    final success = await provider.uploadRecipe(
      title: _titleController.text,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : 'Resep ${_titleController.text} yang lezat dan mudah dibuat.',
      ingredients: ingredients,
      instructions: instructions,
      durationMinutes: int.tryParse(_durationController.text) ?? 30,
      difficulty: _selectedDifficulty,
      category: _selectedCategory,
    );

    if (!mounted) return;

    if (success) {
      // Refresh resep agar langsung muncul di Beranda, Kategori, dan Resep Saya
      context.read<RecipeProvider>().fetchInitialRecipes();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        context.read<RecipeProvider>().fetchMyRecipes(currentUser.uid);
      }

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _SuccessDialog(
          onDone: () {
            Navigator.pop(ctx);
            provider.resetForm();
            Navigator.pop(context);
          },
        ),
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(provider.errorMessage!)),
            ],
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<UploadRecipeProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upload Resep',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!provider.isUploading)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.orange),
              tooltip: 'Reset Form',
              onPressed: () {
                _formKey.currentState?.reset();
                _titleController.clear();
                _descriptionController.clear();
                _durationController.clear();
                for (final c in _ingredientControllers) {
                  c.clear();
                }
                for (final c in _instructionControllers) {
                  c.clear();
                }
                provider.resetForm();
                setState(() {});
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Main Form
          FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image Picker ──
                    _buildImagePicker(provider, isDark),
                    const SizedBox(height: 24),

                    // ── Video Picker ──
                    _buildVideoPicker(provider, isDark),
                    const SizedBox(height: 12),
                    Text(
                      'Video tutorial bersifat opsional. Anda tetap dapat mengunggah resep tanpa video.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Nama Resep ──
                    _buildSectionLabel('Nama Resep', Icons.restaurant_menu),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Contoh: Nasi Goreng Spesial',
                      icon: Icons.edit_rounded,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nama resep wajib diisi'
                          : null,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),

                    // ── Deskripsi ──
                    _buildSectionLabel(
                        'Deskripsi (Opsional)', Icons.description_rounded),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Ceritakan sedikit tentang resep ini...',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),

                    // ── Duration & Difficulty Row ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel(
                                  'Durasi (Menit)', Icons.timer_rounded),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _durationController,
                                hint: '30',
                                icon: Icons.schedule_rounded,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Wajib diisi'
                                    : null,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel(
                                  'Kesulitan', Icons.speed_rounded),
                              const SizedBox(height: 8),
                              _buildDropdown(
                                value: _selectedDifficulty,
                                items: _difficulties,
                                onChanged: (v) => setState(
                                    () => _selectedDifficulty = v ?? 'Menengah'),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Kategori ──
                    _buildSectionLabel('Kategori', Icons.category_rounded),
                    const SizedBox(height: 8),
                    _buildCategorySelector(isDark),
                    const SizedBox(height: 28),

                    // ── Bahan-bahan ──
                    _buildSectionLabel(
                        'Bahan-bahan', Icons.shopping_basket_rounded),
                    const SizedBox(height: 8),
                    _buildDynamicListSection(
                      controllers: _ingredientControllers,
                      hintPrefix: 'Bahan',
                      onAdd: _addIngredient,
                      onRemove: _removeIngredient,
                      isDark: isDark,
                      icon: Icons.fiber_manual_record,
                      iconSize: 8,
                    ),
                    const SizedBox(height: 28),

                    // ── Langkah Memasak ──
                    _buildSectionLabel(
                        'Langkah Memasak', Icons.format_list_numbered_rounded),
                    const SizedBox(height: 8),
                    _buildDynamicListSection(
                      controllers: _instructionControllers,
                      hintPrefix: 'Langkah',
                      onAdd: _addInstruction,
                      onRemove: _removeInstruction,
                      isDark: isDark,
                      isNumbered: true,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // ── Upload Loading Overlay ──
          if (provider.isUploading) _buildUploadOverlay(provider, isDark),

          // ── Upload Button (Bottom) ──
          if (!provider.isUploading)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: _buildUploadButton(),
            ),
        ],
      ),
    );
  }

  // ─── Image Picker Widget ───────────────────────────────────────────────────

  Widget _buildImagePicker(UploadRecipeProvider provider, bool isDark) {
    return GestureDetector(
      onTap: provider.isUploading ? null : _showImageSourceSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: provider.hasImage
                ? Colors.orange.withAlpha(120)
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: provider.hasImage ? 2 : 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: provider.hasImage
              ? [
                  BoxShadow(
                    color: Colors.orange.withAlpha(30),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: provider.hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      provider.imageBytes!,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(150),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Gambar dipilih • Tap untuk mengganti',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: provider.removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(130),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        size: 40,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Tap untuk menambahkan foto',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gunakan kamera atau pilih dari galeri',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── Video Picker Widget ───────────────────────────────────────────────────

  Widget _buildVideoPicker(UploadRecipeProvider provider, bool isDark) {
    return GestureDetector(
      onTap: provider.isUploading ? null : () => provider.pickVideo(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: provider.hasVideo
                ? Colors.orange.withAlpha(120)
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: provider.hasVideo ? 2 : 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: provider.hasVideo
              ? [
                  BoxShadow(
                    color: Colors.orange.withAlpha(30),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: provider.hasVideo
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: isDark ? Colors.grey[850] : Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.video_file_rounded,
                              size: 40, color: Colors.orange),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              provider.videoName ?? 'Video terpilih',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: provider.removeVideo,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(130),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.videocam_rounded,
                        size: 32,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Upload Video (Opsional)',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── Section Label ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  // ─── Text Field ────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.outfit(
        fontSize: 15,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          color: isDark ? Colors.white38 : Colors.grey[400],
        ),
        prefixIcon: Icon(icon, color: Colors.orange, size: 20),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ─── Dropdown ──────────────────────────────────────────────────────────────

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.orange),
          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          style: GoogleFonts.outfit(
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── Category Selector (Chip style) ────────────────────────────────────────

  Widget _buildCategorySelector(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.entries.map((entry) {
        final isSelected = _selectedCategory == entry.key;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)])
                  : null,
              color: isSelected
                  ? null
                  : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]),
              borderRadius: BorderRadius.circular(24),
              border: isSelected
                  ? null
                  : Border.all(
                      color:
                          isDark ? Colors.grey[700]! : Colors.grey[300]!),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.orange.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              entry.value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey[700]),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Dynamic List Section (Ingredients / Steps) ────────────────────────────

  Widget _buildDynamicListSection({
    required List<TextEditingController> controllers,
    required String hintPrefix,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required bool isDark,
    bool isNumbered = false,
    IconData? icon,
    double? iconSize,
  }) {
    return Column(
      children: [
        ...List.generate(controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number/bullet badge
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: isNumbered
                        ? Text(
                            '${index + 1}',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          )
                        : Icon(
                            icon ?? Icons.fiber_manual_record,
                            size: iconSize ?? 8,
                            color: Colors.white,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: controllers[index],
                    maxLines: isNumbered ? 2 : 1,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    validator: (v) {
                      if (index == 0 && (v == null || v.trim().isEmpty)) {
                        return 'Minimal 1 ${hintPrefix.toLowerCase()} wajib diisi';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '$hintPrefix ${index + 1}',
                      hintStyle: GoogleFonts.outfit(
                        color: isDark ? Colors.white30 : Colors.grey[400],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.orange, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                if (controllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        color: Colors.red, size: 22),
                    onPressed: () => onRemove(index),
                    splashRadius: 20,
                  ),
              ],
            ),
          );
        }),

        // Add button
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withAlpha(60),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline_rounded,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tambah $hintPrefix',
                  style: GoogleFonts.outfit(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Upload Overlay ────────────────────────────────────────────────────────

  Widget _buildUploadOverlay(UploadRecipeProvider provider, bool isDark) {
    return AnimatedOpacity(
      opacity: provider.isUploading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: isDark
            ? Colors.black.withAlpha(200)
            : Colors.white.withAlpha(230),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withAlpha(30),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated cooking icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 6.28 * 0.1,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withAlpha(60),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.cloud_upload_rounded,
                        color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mengupload Resep...',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mohon tunggu sebentar',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: provider.uploadProgress > 0
                        ? provider.uploadProgress
                        : null,
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF9800)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(provider.uploadProgress * 100).toInt()}%',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Upload Button ─────────────────────────────────────────────────────────

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: _handleUpload,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'Upload Resep',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Success Dialog ──────────────────────────────────────────────────────────

class _SuccessDialog extends StatefulWidget {
  final VoidCallback onDone;

  const _SuccessDialog({required this.onDone});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withAlpha(30),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withAlpha(60),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Berhasil! 🎉',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Resep Anda berhasil diupload\nke cloud dengan sukses!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: widget.onDone,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Kembali',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
