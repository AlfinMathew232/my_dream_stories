import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  File? _imageFile;
  String? _currentImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    if (user != null) {
      final userModel = await DatabaseService().getUser(user.uid);
      if (userModel != null) {
        setState(() {
          _firstNameController.text = userModel.firstName;
          _lastNameController.text = userModel.lastName;
          _currentImageUrl = userModel.profileImageUrl;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Optimize image size
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.user;

      if (user != null) {
        String? imageUrl = _currentImageUrl;

        // Upload Profile Image if selected
        if (_imageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');

          await storageRef.putFile(_imageFile!);
          imageUrl = await storageRef.getDownloadURL();
        }

        // Update Firestore
        await DatabaseService().updateUserProfile(user.uid, {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'profileImageUrl': imageUrl,
        });

        // Update Password if provided
        if (_passwordController.text.isNotEmpty) {
          final error = await authService.updatePassword(
            _passwordController.text,
          );
          if (error != null) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Password Error: $error')));
            }
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_currentImageUrl != null
                                            ? CachedNetworkImageProvider(
                                                _currentImageUrl!,
                                              )
                                            : null)
                                        as ImageProvider?,
                              child:
                                  (_imageFile == null &&
                                      _currentImageUrl == null)
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'New Password (Optional)',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      hint: 'Leave blank to keep current',
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }
}
