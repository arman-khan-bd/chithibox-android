import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final _baseUrlController = TextEditingController();

  bool _isEditingProfile = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _usernameController.text = user.username;
      _displayNameController.text = user.displayName ?? '';
    }
    _baseUrlController.text = context.read<AuthProvider>().apiService.baseUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    final username = _usernameController.text.trim().toLowerCase();
    final displayName = _displayNameController.text.trim();

    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      username: username,
      displayName: displayName,
    );

    if (mounted) {
      if (success) {
        setState(() => _isEditingProfile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('প্রোফাইল সফলভাবে আপডেট করা হয়েছে'),
            backgroundColor: AppTheme.postalGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'প্রোফাইল আপডেট ব্যর্থ হয়েছে'),
            backgroundColor: AppTheme.postalRed,
          ),
        );
      }
    }
  }

  Future<void> _handleSavePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    final auth = context.read<AuthProvider>();
    final success = await auth.updatePassword(
      currentPassword: currentPassword.isNotEmpty ? currentPassword : null,
      newPassword: newPassword,
    );

    if (mounted) {
      if (success) {
        setState(() {
          _isChangingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে'),
            backgroundColor: AppTheme.postalGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'পাসওয়ার্ড পরিবর্তন ব্যর্থ হয়েছে'),
            backgroundColor: AppTheme.postalRed,
          ),
        );
      }
    }
  }

  Future<void> _handleSaveBaseUrl() async {
    final url = _baseUrlController.text.trim();
    if (url.isEmpty) return;

    await context.read<AuthProvider>().setCustomBaseUrl(url);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সার্ভার ঠিকানা সংরক্ষিত হয়েছে')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('প্রবেশ করা নেই')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'প্রোফাইল ও সেটিংস',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.parchmentBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryLight,
                    child: Text(
                      user.displayNameOrUsername.isNotEmpty
                          ? user.displayNameOrUsername[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.displayNameOrUsername,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.inkNavy,
                    ),
                  ),
                  Text(
                    '@${user.username}',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      color: AppTheme.inkMuted,
                    ),
                  ),
                  if (user.phone != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '📱 ${user.phone}',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        color: AppTheme.inkSubtle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Edit Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ব্যক্তিগত তথ্য',
                          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        IconButton(
                          icon: Icon(_isEditingProfile ? Icons.close : Icons.edit_outlined, size: 20),
                          onPressed: () {
                            setState(() => _isEditingProfile = !_isEditingProfile);
                          },
                        ),
                      ],
                    ),
                    if (_isEditingProfile) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'ইউজারনেম (@username)',
                          hintText: 'user_xyz',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'প্রদর্শিত নাম (Display Name)',
                          hintText: 'আপনার পুরো নাম',
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleSaveProfile,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('তথ্য সংরক্ষণ করুন'),
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text('ইউজারনেম: @${user.username}', style: GoogleFonts.hindSiliguri(color: AppTheme.inkNavy)),
                      const SizedBox(height: 4),
                      Text('নাম: ${user.displayName ?? "নির্ধারণ করা নেই"}',
                          style: GoogleFonts.hindSiliguri(color: AppTheme.inkNavy)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password Change Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'নিরাপত্তা ও পাসওয়ার্ড',
                          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        IconButton(
                          icon: Icon(_isChangingPassword ? Icons.close : Icons.lock_reset, size: 20),
                          onPressed: () {
                            setState(() => _isChangingPassword = !_isChangingPassword);
                          },
                        ),
                      ],
                    ),
                    if (_isChangingPassword) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'বর্তমান পাসওয়ার্ড (থাকলে)',
                          hintText: '••••••••',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'নতুন পাসওয়ার্ড (কমপক্ষে ৬ অক্ষর)',
                          hintText: '••••••••',
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleSavePassword,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('পাসওয়ার্ড আপডেট করুন'),
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        user.hasPassword
                            ? 'আপনার একাউন্টে পাসওয়ার্ড সক্রিয় আছে।'
                            : 'এখনো কোনো পাসওয়ার্ড সেট করা হয়নি (সরাসরি ওটিপি দিয়ে লগইন প্রযোজ্য)।',
                        style: GoogleFonts.hindSiliguri(color: AppTheme.inkMuted, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Server Base URL Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'সার্ভার সংযোগ (API Base URL)',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ডিফল্ট সার্ভার: https://gb.e-bd.shop',
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppTheme.inkMuted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _baseUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Base URL',
                              hintText: 'https://gb.e-bd.shop',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _handleSaveBaseUrl,
                          child: const Text('সংরক্ষণ'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.postalRed,
                side: const BorderSide(color: AppTheme.postalRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('লগআউট করতে চান?'),
                    content: const Text('আপনি আপনার চিঠিবক্স অ্যাকাউন্ট থেকে বের হয়ে যাবেন।'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('না')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.postalRed),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('লগআউট'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await auth.logout();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('লগআউট করুন'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
