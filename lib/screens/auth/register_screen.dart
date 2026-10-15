import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _otpCodeController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSendingOtp = false;
  bool _obscurePassword = true;
  String? _devOtp;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpCodeController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মোবাইল নম্বর লিখুন')),
      );
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _devOtp = null;
    });

    final auth = context.read<AuthProvider>();
    final res = await auth.sendOtp(phone, 'register');

    setState(() {
      _isSendingOtp = false;
    });

    if (res.success) {
      final code = res.data?['devOtp']?.toString();
      setState(() {
        _devOtp = code;
      });
      if (code != null) {
        _otpCodeController.text = code;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ওটিপি কোড পাঠানো হয়েছে')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.error ?? 'ওটিপি পাঠাতে ব্যর্থ হয়েছে'),
            backgroundColor: AppTheme.postalRed,
          ),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    final phone = _phoneController.text.trim();
    final code = _otpCodeController.text.trim();
    final displayName = _displayNameController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মোবাইল ও ওটিপি কোড আবশ্যক')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      phone: phone,
      code: code,
      displayName: displayName.isNotEmpty ? displayName : null,
      password: password.isNotEmpty ? password : null,
    );

    if (success) {
      if (mounted) {
        Navigator.pop(context); // Go back or auth provider state will auto-route to Home
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'রেজিস্ট্রেশন ব্যর্থ হয়েছে'),
            backgroundColor: AppTheme.postalRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'নতুন চিঠিবক্স একাউন্ট',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ডাকঘরে স্বাগত!',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.inkNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'আপনার মোবাইল নম্বর যাচাই করে বিনামূল্যে চিঠিবক্স খুলুন।',
                    style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppTheme.inkMuted),
                  ),
                  const SizedBox(height: 24),

                  // Phone Input + Send OTP
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'মোবাইল নম্বর',
                            hintText: '01712345678',
                            prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _isSendingOtp ? null : _handleSendOtp,
                          child: _isSendingOtp
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('ওটিপি পাঠান'),
                        ),
                      ),
                    ],
                  ),
                  if (_devOtp != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.amberLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.accentAmber.withOpacity(0.4)),
                      ),
                      child: Text(
                        'ডেভেলপমেন্ট ওটিপি: $_devOtp (স্বয়ংক্রিয়ভাবে বসানো হয়েছে)',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          color: AppTheme.amberDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // OTP Code Input
                  TextField(
                    controller: _otpCodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '৬ ডিজিটের ওটিপি কোড',
                      prefixIcon: Icon(Icons.pin_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Full Name
                  TextField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'আপনার নাম (ঐচ্ছিক)',
                      hintText: 'উদাঃ রবি ঠাকুর',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'পাসওয়ার্ড সেট করুন (ঐচ্ছিক)',
                      hintText: 'পরবর্তীতে সরাসরি লগইনের জন্য',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleRegister,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('চিঠিবক্স খুলুন'),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'ইতিমধ্যে একাউন্ট আছে?',
                        style: GoogleFonts.hindSiliguri(color: AppTheme.inkMuted),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'লগইন করুন',
                          style: GoogleFonts.hindSiliguri(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
