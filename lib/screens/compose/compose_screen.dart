import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/chithi_provider.dart';
import '../../theme/app_theme.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final _placeController = TextEditingController(text: 'ঢাকা');
  final _salutationController = TextEditingController(text: 'প্রিয় সুহৃদ,');
  final _closingController = TextEditingController(text: 'ইতি,');
  final _signatureController = TextEditingController();

  bool _isAnonymous = false;
  String? _recipientCheckStatus;
  bool _isCheckingRecipient = false;
  bool _isRecipientValid = false;

  // Selected Stationery Options
  String _selectedTheme = 'vintage_parchment';
  String _selectedEnvelope = 'classic_khaki';
  String _selectedStamp = 'shapla';
  String _selectedSeal = 'crimson_lotus';
  String _selectedInkColor = '#1e3a8a';

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChithiProvider>().loadCatalog();
    });
  }

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    _placeController.dispose();
    _salutationController.dispose();
    _closingController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _checkRecipient() async {
    final query = _toController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isCheckingRecipient = true;
      _recipientCheckStatus = null;
      _isRecipientValid = false;
    });

    final res = await context.read<ChithiProvider>().checkRecipient(query);

    setState(() {
      _isCheckingRecipient = false;
      if (res.success && res.data?['isValid'] == true) {
        _isRecipientValid = true;
        _recipientCheckStatus = 'প্রাপক: ${res.data!['display']}';
      } else {
        _isRecipientValid = false;
        _recipientCheckStatus = res.data?['error'] ?? 'প্রাপক পাওয়া যায়নি';
      }
    });
  }

  Future<void> _handleSend() async {
    final to = _toController.text.trim();
    final body = _bodyController.text.trim();

    if (to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রাপকের নাম/মোবাইল উল্লেখ করুন')),
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('চিঠির মূল বক্তব্য লিখুন')),
      );
      setState(() => _currentStep = 1);
      return;
    }

    final chithiProv = context.read<ChithiProvider>();

    final payload = {
      'to': to,
      'subject': _subjectController.text.trim().isNotEmpty ? _subjectController.text.trim() : null,
      'body': body,
      'place': _placeController.text.trim().isNotEmpty ? _placeController.text.trim() : null,
      'salutation': _salutationController.text.trim().isNotEmpty ? _salutationController.text.trim() : null,
      'closing': _closingController.text.trim().isNotEmpty ? _closingController.text.trim() : null,
      'signature': _signatureController.text.trim().isNotEmpty ? _signatureController.text.trim() : null,
      'theme': _selectedTheme,
      'envelopeDesign': _selectedEnvelope,
      'stampDesign': _selectedStamp,
      'sealDesign': _selectedSeal,
      'fontColor': _selectedInkColor,
      'isAnonymous': _isAnonymous,
    };

    final res = await chithiProv.sendLetter(payload);

    if (res.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('চিঠিটি সফলভাবে ডাকঘরে পাঠানো হয়েছে!'),
          backgroundColor: AppTheme.postalGreen,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.error ?? 'চিঠি পাঠাতে ব্যর্থ হয়েছে'),
          backgroundColor: AppTheme.postalRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chithiProv = context.watch<ChithiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'নতুন চিঠি রচনা',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: chithiProv.isLoading ? null : _handleSend,
            icon: chithiProv.isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  )
                : const Icon(Icons.send_rounded, size: 18, color: AppTheme.primary),
            label: Text(
              'প্রেরণ',
              style: GoogleFonts.hindSiliguri(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            _handleSend();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 2 ? 'চিঠি পাঠান' : 'পরবর্তী ধাপ'),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('পেছনে'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Step 1: Recipient
          Step(
            title: Text('১. প্রাপক নির্বাচন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
            isActive: _currentStep >= 0,
            state: _toController.text.isNotEmpty ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _toController,
                        decoration: const InputDecoration(
                          labelText: 'প্রাপক (@ইউজারনেম বা মোবাইল নম্বর)',
                          hintText: '@username বা 01712345678',
                          prefixIcon: Icon(Icons.alternate_email, size: 20),
                        ),
                        onSubmitted: (_) => _checkRecipient(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _isCheckingRecipient ? null : _checkRecipient,
                        child: _isCheckingRecipient
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('যাচাই'),
                      ),
                    ),
                  ],
                ),
                if (_recipientCheckStatus != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isRecipientValid ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isRecipientValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isRecipientValid ? Icons.check_circle : Icons.error_outline,
                          size: 16,
                          color: _isRecipientValid ? AppTheme.postalGreen : AppTheme.postalRed,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _recipientCheckStatus!,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isRecipientValid ? AppTheme.postalGreen : AppTheme.postalRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'বেনামী চিঠি (Anonymous)',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    'প্রাপক আপনার আসল নাম ও প্রোফাইল দেখতে পাবেন না।',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppTheme.inkMuted),
                  ),
                  value: _isAnonymous,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => setState(() => _isAnonymous = val),
                ),
              ],
            ),
          ),

          // Step 2: Write Letter Content
          Step(
            title: Text('২. চিঠি লিখন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
            isActive: _currentStep >= 1,
            state: _bodyController.text.isNotEmpty ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _placeController,
                        decoration: const InputDecoration(labelText: 'স্থান', hintText: 'ঢাকা'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _salutationController,
                        decoration: const InputDecoration(labelText: 'সম্বোধন', hintText: 'প্রিয়তম/সুহৃদ,'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'চিঠির বিষয় (ঐচ্ছিক)',
                    hintText: 'উদাঃ শরতের মেঘের চিঠি',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _bodyController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'চিঠির মূল বক্তব্য *',
                    hintText: 'আপনার মনের কথা এখানে লিখুন...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _closingController,
                        decoration: const InputDecoration(labelText: 'বিদায় সম্ভাষণ', hintText: 'ইতি,'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _signatureController,
                        decoration: const InputDecoration(labelText: 'স্বাক্ষর', hintText: 'আপনার নাম'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Step 3: Stationery Customization
          Step(
            title: Text('৩. ডাকটিকিট ও সিলগালা', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Envelope picker
                Text('ডাক খাম নির্বাচন:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStationeryChip(
                        id: 'classic_khaki',
                        name: 'ঐতিহ্যবাহী খাকি',
                        icon: '✉️',
                        selected: _selectedEnvelope == 'classic_khaki',
                        onTap: () => setState(() => _selectedEnvelope = 'classic_khaki'),
                      ),
                      _buildStationeryChip(
                        id: 'vintage_parchment',
                        name: 'ভিন্টেজ পার্চমেন্ট',
                        icon: '📜',
                        selected: _selectedEnvelope == 'vintage_parchment',
                        onTap: () => setState(() => _selectedEnvelope = 'vintage_parchment'),
                      ),
                      _buildStationeryChip(
                        id: 'love_rose',
                        name: 'গোলাপী মখমল',
                        icon: '💌',
                        selected: _selectedEnvelope == 'love_rose',
                        onTap: () => setState(() => _selectedEnvelope = 'love_rose'),
                      ),
                      _buildStationeryChip(
                        id: 'zamindar_royal',
                        name: 'জমিদারী রাজকীয়',
                        icon: '👑',
                        selected: _selectedEnvelope == 'zamindar_royal',
                        onTap: () => setState(() => _selectedEnvelope = 'zamindar_royal'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Stamp picker
                Text('ডাক টিকিট:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStationeryChip(
                        id: 'shapla',
                        name: 'জাতীয় শাপলা',
                        icon: '🌸',
                        selected: _selectedStamp == 'shapla',
                        onTap: () => setState(() => _selectedStamp = 'shapla'),
                      ),
                      _buildStationeryChip(
                        id: 'tiger',
                        name: 'রয়েল বেঙ্গল টাইগার',
                        icon: '🐅',
                        selected: _selectedStamp == 'tiger',
                        onTap: () => setState(() => _selectedStamp = 'tiger'),
                      ),
                      _buildStationeryChip(
                        id: 'postbox',
                        name: 'লাল ডাকবাক্স',
                        icon: '📮',
                        selected: _selectedStamp == 'postbox',
                        onTap: () => setState(() => _selectedStamp = 'postbox'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Wax Seal picker
                Text('গালা সিলমোহর:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStationeryChip(
                        id: 'crimson_lotus',
                        name: 'রক্তপদ্ম মোহর',
                        icon: '💮',
                        selected: _selectedSeal == 'crimson_lotus',
                        onTap: () => setState(() => _selectedSeal = 'crimson_lotus'),
                      ),
                      _buildStationeryChip(
                        id: 'gold_royal',
                        name: 'স্বর্ণালী মোহর',
                        icon: '⚜️',
                        selected: _selectedSeal == 'gold_royal',
                        onTap: () => setState(() => _selectedSeal = 'gold_royal'),
                      ),
                      _buildStationeryChip(
                        id: 'heart_love',
                        name: 'ভালোবাসার হৃদয়',
                        icon: '💖',
                        selected: _selectedSeal == 'heart_love',
                        onTap: () => setState(() => _selectedSeal = 'heart_love'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Paper Style
                Text('কাগজের পাতা:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStationeryChip(
                        id: 'vintage_parchment',
                        name: 'ভিন্টেজ পার্চমেন্ট',
                        icon: '📜',
                        selected: _selectedTheme == 'vintage_parchment',
                        onTap: () => setState(() => _selectedTheme = 'vintage_parchment'),
                      ),
                      _buildStationeryChip(
                        id: 'notebook',
                        name: 'ডায়েরির রুলটানা পাতা',
                        icon: '📓',
                        selected: _selectedTheme == 'notebook',
                        onTap: () => setState(() => _selectedTheme = 'notebook'),
                      ),
                      _buildStationeryChip(
                        id: 'burnt_manuscript',
                        name: 'পোড়া পাণ্ডুলিপি',
                        icon: '🔥',
                        selected: _selectedTheme == 'burnt_manuscript',
                        onTap: () => setState(() => _selectedTheme = 'burnt_manuscript'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Ink Color
                Text('কলমের কালির রঙ:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInkCircle('#1e3a8a', 'ঝরনা নীল'),
                    _buildInkCircle('#0f172a', 'কালো নিব'),
                    _buildInkCircle('#451a03', 'সেপিয়া বাদামি'),
                    _buildInkCircle('#881337', 'আলতা লাল'),
                    _buildInkCircle('#064e3b', 'হরিত সবুজ'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationeryChip({
    required String id,
    required String name,
    required String icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.parchmentBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                name,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? AppTheme.primary : AppTheme.inkNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInkCircle(String hex, String label) {
    final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
    final selected = _selectedInkColor == hex;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: () => setState(() => _selectedInkColor = hex),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppTheme.primary : Colors.white,
                width: selected ? 3 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: selected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}
