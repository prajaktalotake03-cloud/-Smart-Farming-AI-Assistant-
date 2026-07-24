import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _updatePhoto(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (!mounted) return;
        Provider.of<ProfileProvider>(context, listen: false).updatePhoto(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error picking profile photo: $e');
    }
  }

  void _showPhotoSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Photo',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.emeraldGreen),
                title: const Text('Take Photo from Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _updatePhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.emeraldGreen),
                title: const Text('Select Photo from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _updatePhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(ProfileProvider profile) {
    final nameController = TextEditingController(text: profile.name);
    final villageController = TextEditingController(text: profile.village);
    final farmSizeController = TextEditingController(text: profile.farmSize);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Profile Details',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Farmer Name',
                  floatingLabelStyle: TextStyle(color: AppTheme.emeraldGreen),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: villageController,
                decoration: const InputDecoration(
                  labelText: 'Village Name',
                  floatingLabelStyle: TextStyle(color: AppTheme.emeraldGreen),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: farmSizeController,
                decoration: const InputDecoration(
                  labelText: 'Farm Size (Acres)',
                  floatingLabelStyle: TextStyle(color: AppTheme.emeraldGreen),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                profile.updateProfile(
                  name: nameController.text.trim(),
                  village: villageController.text.trim(),
                  farmSize: farmSizeController.text.trim(),
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldGreen),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profile = Provider.of<ProfileProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final List<String> languages = ['English', 'Hindi', 'Marathi', 'Gujarati'];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Farmer Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Card Header
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  // Photo Avatar
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.emeraldGreen, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.emeraldGreen.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: profile.photoPath != null
                              ? Image.file(
                                  File(profile.photoPath!),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppTheme.emeraldGreen.withOpacity(0.08),
                                  alignment: Alignment.center,
                                  child: Text(
                                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'F',
                                    style: GoogleFonts.outfit(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.emeraldGreen,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showPhotoSelector,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.emeraldGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name details
                  Text(
                    profile.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Village: ${profile.village}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Mini details Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoBadge(theme, '🚜 Farm Size', profile.farmSize),
                      const SizedBox(width: 12),
                      _buildInfoBadge(theme, '🗣️ Language', profile.language),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile Actions
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  // Action list cards
                  Card(
                    elevation: 0,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit_outlined, color: AppTheme.emeraldGreen),
                          title: const Text('Edit Profile Details'),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () => _showEditProfileDialog(profile),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        
                        // Language Selector dropdown tile
                        ListTile(
                          leading: const Icon(Icons.language_outlined, color: AppTheme.emeraldGreen),
                          title: const Text('Preferred Language'),
                          trailing: DropdownButton<String>(
                            value: profile.language,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.emeraldGreen),
                            dropdownColor: isDark ? const Color(0xFF13251A) : Colors.white,
                            items: languages.map((lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang, style: const TextStyle(fontSize: 14)),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                profile.updateLanguage(val);
                              }
                            },
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),

                        // Notifications switch tile
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications_none_outlined, color: AppTheme.emeraldGreen),
                          title: const Text('Push Notifications'),
                          activeColor: AppTheme.emeraldGreen,
                          value: profile.notificationsEnabled,
                          onChanged: profile.toggleNotifications,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),

                        // Dark mode switch tile
                        SwitchListTile(
                          secondary: const Icon(Icons.dark_mode_outlined, color: AppTheme.emeraldGreen),
                          title: const Text('Dark Mode'),
                          activeColor: AppTheme.emeraldGreen,
                          value: themeProvider.isDarkMode(context),
                          onChanged: (isOn) {
                            themeProvider.toggleTheme(isOn);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Confirm sign out
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text('Are you sure you want to log out of your farming account?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await auth.logout();
                                  if (context.mounted) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.redAccent.withOpacity(0.9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.emeraldGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.emeraldGreen,
            ),
          ),
        ],
      ),
    );
  }
}
