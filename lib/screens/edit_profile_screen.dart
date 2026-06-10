import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/profile_provider.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;

  File? _imageFile;
  bool _removePhoto = false;
  final ImagePicker _picker = ImagePicker();

  UserModel? _currentUserData;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _bioController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final provider = context.read<ProfileProvider>();
    if (provider.user != null) {
      setState(() {
        _currentUserData = provider.user;
        _nameController.text = _currentUserData!.name;
        _usernameController.text = _currentUserData!.username;
        _phoneController.text = _currentUserData!.phone;
        _addressController.text = _currentUserData!.address;
        _bioController.text = _currentUserData!.bio;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _removePhoto = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  void _showImageOptions() {
    final bool hasPhoto = _imageFile != null ||
        (_currentUserData?.profileImage != null &&
            _currentUserData!.profileImage!.isNotEmpty);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Foto Profil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.photo_library, color: Colors.white),
                  ),
                  title: const Text('Ganti Foto'),
                  subtitle: const Text('Pilih foto dari galeri'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage();
                  },
                ),
                if (hasPhoto) ...[
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    title: const Text(
                      'Hapus Foto Profil',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('Foto akan dihapus saat Anda menyimpan'),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _imageFile = null;
                        _removePhoto = true;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi telah kedaluwarsa. Silakan login ulang.')),
      );
      return;
    }

    final provider = context.read<ProfileProvider>();
    
    // Hapus foto profil jika diminta
    if (_removePhoto) {
      final success = await provider.removeProfileImage(authUser.uid);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal menghapus foto profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Upload gambar dulu jika ada
    String? imageUrl = _currentUserData?.profileImage;
    if (_imageFile != null) {
      final url = await provider.uploadProfileImage(authUser.uid, _imageFile!);
      if (url != null) {
        imageUrl = url;
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Gagal mengupload gambar')),
        );
        return;
      }
    }

    // Buat objek UserModel baru (atau update yang lama)
    final updatedUser = UserModel(
      uid: authUser.uid,
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: authUser.email ?? '',
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      bio: _bioController.text.trim(),
      profileImage: imageUrl,
    );

    final success = await provider.updateProfile(updatedUser);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.successMessage ?? 'Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal memperbarui profil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProfileProvider>();
    final authUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
      ),
      body: authUser == null
          ? const Center(child: Text('Sesi kedaluwarsa. Silakan login ulang.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar & Upload Button
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              border: Border.all(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: _imageFile != null
                                  ? Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : (!_removePhoto &&
                                          _currentUserData?.profileImage != null &&
                                          _currentUserData!.profileImage!.isNotEmpty)
                                      ? Image.network(
                                          _currentUserData!.profileImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 60,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                            ),
                          ),
                          // Badge hapus foto (saat _removePhoto aktif)
                          if (_removePhoto)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0x99000000),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.no_photography,
                                  color: Colors.white54,
                                  size: 36,
                                ),
                              ),
                            ),
                          // Tombol ganti/hapus foto
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageOptions,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _removePhoto ? Colors.red : Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _removePhoto ? Icons.delete : Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Read-only fields
                    _buildTextField(
                      label: 'UID',
                      initialValue: authUser.uid,
                      enabled: false,
                      icon: Icons.vpn_key_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Email',
                      initialValue: authUser.email,
                      enabled: false,
                      icon: Icons.email_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Editable fields
                    _buildTextFormField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.alternate_email,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty && value.trim().length < 3) {
                          return 'Username minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _phoneController,
                      label: 'Nomor Telepon',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final RegExp phoneRegExp = RegExp(r'^[0-9]+$');
                          if (!phoneRegExp.hasMatch(value)) {
                            return 'Nomor telepon hanya boleh berisi angka';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _addressController,
                      label: 'Alamat',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _bioController,
                      label: 'Bio Singkat',
                      icon: Icons.info_outline,
                      maxLines: 3,
                      maxLength: 200,
                    ),
                    
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'SIMPAN PROFIL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.2,
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

  Widget _buildTextField({
    required String label,
    required String? initialValue,
    required bool enabled,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      style: TextStyle(color: Colors.grey[500]),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[900] 
            : Colors.grey[100],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[700]! 
                : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }
}
