import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Password Login Controllers
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // OTP Login Controllers
  final _phoneController = TextEditingController();
  final _otpCodeController = TextEditingController();
  bool _isSendingOtp = false;
  String? _devOtp;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpCodeController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ইউজারনেম/মোবাইল এবং পাসওয়ার্ড প্রদান করুন')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithPassword(identifier, password);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'লগইন ব্যর্থ হয়েছে'),
          backgroundColor: AppTheme.postalRed,
        ),
      );
    }
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক মোবাইল নম্বর লিখুন')),
      );
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _devOtp = null;
    });

    final auth = context.read<AuthProvider>();
    final res = await auth.sendOtp(phone, 'login');

    setState(() {
      _isSendingOtp = false;
    });

    if (res.success) {
      final devCode = res.data?['devOtp']?.toString();
      setState(() {
        _devOtp = devCode;
      });
      if (devCode != null) {
        _otpCodeController.text = devCode;
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.error ?? 'ওটিপি পাঠাতে সমস্যা হয়েছে'),
            backgroundColor: AppTheme.postalRed,
          ),
        );
      }
    }
  }

  Future<void> _handleOtpLogin() async {
    final phone = _phoneController.text.trim();
    final code = _otpCodeController.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মোবাইল ও ওটিপি কোড লিখুন')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithOtp(phone, code);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'ওটিপি যাচাই ব্যর্থ হয়েছে'),
          backgroundColor: AppTheme.postalRed,
        ),
      );
    }
  }

  void _showServerSettingsDialog() {
    final auth = context.read<AuthProvider>();
    final controller = TextEditingController(text: auth.apiService.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('সার্ভার সংযোগ ঠিকানা (API Base URL)',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ডিফল্ট সার্ভার: https://gb.e-bd.shop',
              style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppTheme.inkMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'https://gb.e-bd.shop',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.setCustomBaseUrl(controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.inkMuted),
            tooltip: 'সার্ভার সেটিংস',
            onPressed: _showServerSettingsDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Brand Icon & Title
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('📮', style: TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'চিঠিবক্স',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.inkNavy,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'হৃদয়ের অনুভূতি, ঐতিহ্যের ডাকপিয়ন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      color: AppTheme.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tab Switcher (Password vs OTP)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: AppTheme.primary,
                      unselectedLabelColor: AppTheme.inkMuted,
                      labelStyle: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: 'পাসওয়ার্ড'),
                        Tab(text: 'ওটিপি কোড'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab Views
                  SizedBox(
                    height: 280,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Password Login
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _identifierController,
                              decoration: const InputDecoration(
                                labelText: 'ইউজারনেম / মোবাইল / ইমেইল',
                                prefixIcon: Icon(Icons.person_outline, size: 20),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'পাসওয়ার্ড',
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
                            const Spacer(),
                            ElevatedButton(
                              onPressed: auth.isLoading ? null : _handlePasswordLogin,
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('প্রবেশ করুন'),
                            ),
                          ],
                        ),

                        // Tab 2: OTP Login
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                  'ডেভেলপমেন্ট ওটিপি কোড: $_devOtp (স্বয়ংক্রিয়ভাবে বসানো হয়েছে)',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 12,
                                    color: AppTheme.amberDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            TextField(
                              controller: _otpCodeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: '৬ ডিজিটের ওটিপি কোড',
                                prefixIcon: Icon(Icons.pin_outlined, size: 20),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: auth.isLoading ? null : _handleOtpLogin,
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('যাচাই ও প্রবেশ'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register link
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'চিঠিবক্সে নতুন?',
                        style: GoogleFonts.hindSiliguri(color: AppTheme.inkMuted),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'রেজিস্টার করুন',
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
