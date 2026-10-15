import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/chithi.dart';
import '../../providers/chithi_provider.dart';
import '../../theme/app_theme.dart';

class ChithiReaderScreen extends StatefulWidget {
  final String letterId;

  const ChithiReaderScreen({super.key, required this.letterId});

  @override
  State<ChithiReaderScreen> createState() => _ChithiReaderScreenState();
}

class _ChithiReaderScreenState extends State<ChithiReaderScreen>
    with SingleTickerProviderStateMixin {
  ChithiModel? _letter;
  bool _isLoading = true;
  String? _errorMessage;

  // Envelope Interactive State
  bool _isOpen = false;
  bool _showBackSide = true; // True: Wax Seal side, False: Address front side
  bool _isSealBroken = false;

  late AnimationController _openAnimController;
  late Animation<double> _unfoldAnimation;

  @override
  void initState() {
    super.initState();

    _openAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _unfoldAnimation = CurvedAnimation(
      parent: _openAnimController,
      curve: Curves.easeOutCubic,
    );

    _loadLetter();
  }

  @override
  void dispose() {
    _openAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadLetter() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final chithiProv = context.read<ChithiProvider>();
    final letter = await chithiProv.getLetterDetails(widget.letterId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (letter != null) {
          _letter = letter;
          // If already read previously, user can tap to open or auto-open
        } else {
          _errorMessage = 'চিঠিটি খুঁজে পাওয়া যায়নি';
        }
      });
    }
  }

  void _breakSealAndOpen() {
    if (_isSealBroken) return;

    setState(() {
      _isSealBroken = true;
    });

    // Short tactile delay before letter unfolds
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isOpen = true;
        });
        _openAnimController.forward();
      }
    });
  }

  void _closeBackToEnvelope() {
    _openAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isOpen = false;
          _isSealBroken = false;
        });
      }
    });
  }

  Color _resolveInkColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF1E293B);
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return const Color(0xFF1E293B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chithiProv = context.watch<ChithiProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3ECE0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isOpen ? 'চিঠিপত্র পাঠ' : 'ডাক খাম',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (_letter != null && _isOpen) ...[
            IconButton(
              icon: Icon(
                _letter!.isStarred ? Icons.star : Icons.star_border,
                color: _letter!.isStarred ? AppTheme.accentAmber : AppTheme.inkNavy,
              ),
              tooltip: 'তারকাচিহ্নিত',
              onPressed: () async {
                final starred = await chithiProv.toggleStar(_letter!.id);
                setState(() {
                  _letter = _letter!.copyWith(isStarred: starred);
                });
              },
            ),
            IconButton(
              icon: Icon(
                _letter!.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                color: AppTheme.inkNavy,
              ),
              tooltip: _letter!.isArchived ? 'পুনরুদ্ধার' : 'সংরক্ষণ',
              onPressed: () async {
                final archived = await chithiProv.toggleArchive(_letter!.id);
                if (mounted) {
                  setState(() {
                    _letter = _letter!.copyWith(isArchived: archived);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(archived ? 'চিঠিটি সংরক্ষিত হয়েছে' : 'চিঠিটি ইনবক্সে ফিরিয়ে আনা হয়েছে'),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.mail_outline, color: AppTheme.inkNavy),
              tooltip: 'খামে ফেরত যান',
              onPressed: _closeBackToEnvelope,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.hindSiliguri(color: AppTheme.postalRed, fontSize: 16),
                  ),
                )
              : _letter == null
                  ? const SizedBox()
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _isOpen ? _buildLetterCanvas() : _buildEnvelopeView(),
                    ),
    );
  }

  // --- 1. Envelope View (Realistic Envelope with wax seal and flip side) ---
  Widget _buildEnvelopeView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Envelope Container
            Container(
              width: 340,
              height: 230,
              decoration: BoxDecoration(
                color: const Color(0xFFF7EED9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4B886), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    // Vintage Airmail border stripes on front side
                    if (!_showBackSide)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 8,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red, Colors.blue, Colors.white, Colors.red],
                              stops: [0.25, 0.5, 0.75, 1.0],
                              tileMode: TileMode.repeated,
                            ),
                          ),
                        ),
                      ),

                    // Back Side: Flap and Wax Seal
                    if (_showBackSide) ...[
                      // Flap Triangle Background
                      CustomPaint(
                        size: const Size(340, 230),
                        painter: _EnvelopeFlapPainter(),
                      ),

                      // Interactive Wax Seal in Center
                      Center(
                        child: GestureDetector(
                          onTap: _breakSealAndOpen,
                          child: AnimatedScale(
                            scale: _isSealBroken ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: _isSealBroken
                                      ? [const Color(0xFF7F1D1D), const Color(0xFF450A0A)]
                                      : [const Color(0xFFDC2626), const Color(0xFF991B1B)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFF7F1D1D),
                                  width: 2.5,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isSealBroken ? '💥' : 'চিঠি',
                                      style: GoogleFonts.hindSiliguri(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (!_isSealBroken)
                                      Text(
                                        '★ মোহর ★',
                                        style: GoogleFonts.hindSiliguri(
                                          color: Colors.white70,
                                          fontSize: 9,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Front Side: Postal Stamp & Recipient / Sender Addresses
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Container(
                          width: 52,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.red.shade900, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _letter!.stampDesign == 'tiger'
                                    ? '🐅'
                                    : _letter!.stampDesign == 'postbox'
                                        ? '📮'
                                        : '🌸',
                                style: const TextStyle(fontSize: 22),
                              ),
                              Text(
                                'ডাক ৳১০',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // To / From Address text
                      Positioned(
                        bottom: 24,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'প্রাপক (To): ${_letter!.recipientDisplay ?? "সুহৃদ"}',
                              style: GoogleFonts.hindSiliguri(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: const Color(0xFF2B180A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'প্রেরক (From): ${_letter!.senderDisplay.name}',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 12,
                                color: const Color(0xFF5A3C23),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Flip sides button
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _showBackSide = !_showBackSide);
              },
              icon: const Icon(Icons.rotate_90_degrees_cw_outlined, size: 18),
              label: Text(
                _showBackSide ? 'সামনের ঠিকানা দেখুন' : 'পেছনের সিলগালা দেখুন',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // Instruction prompt
            Text(
              _showBackSide
                  ? 'সিলমোহরে ট্যাপ করে চিঠিটি খুলুন ✨'
                  : 'ডাক বিভাগের আনুষ্ঠানিক খাম',
              style: GoogleFonts.hindSiliguri(
                fontSize: 13,
                color: AppTheme.inkMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Letter Canvas (Parchment Paper with handwriting text) ---
  Widget _buildLetterCanvas() {
    final dateFormat = DateFormat('dd MMMM, yyyy');
    final formattedDate = dateFormat.format(_letter!.createdAt);
    final inkColor = _resolveInkColor(_letter!.fontColor);

    return ScaleTransition(
      scale: _unfoldAnimation,
      child: FadeTransition(
        opacity: _unfoldAnimation,
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 2.5,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF4E6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2D1B3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Place & Date Header (Top Right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📜 চিঠিবক্স পত্র',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          color: const Color(0xFF8C6D4F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_letter!.place != null && _letter!.place!.isNotEmpty)
                            Text(
                              _letter!.place!,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 13,
                                color: const Color(0xFF5C3E20),
                              ),
                            ),
                          Text(
                            _letter!.letterDate ?? formattedDate,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: const Color(0xFF7A5836),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE2D1B3), height: 28),

                  // Salutation
                  if (_letter!.salutation != null && _letter!.salutation!.isNotEmpty) ...[
                    Text(
                      _letter!.salutation!,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: inkColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Subject (if available)
                  if (_letter!.subject != null && _letter!.subject!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'বিষয়: ${_letter!.subject!}',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: inkColor.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],

                  // Body with handwriting feel
                  Text(
                    _letter!.body,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      height: 1.8,
                      color: inkColor,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Closing & Signature (Bottom Right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_letter!.closing != null && _letter!.closing!.isNotEmpty)
                          Text(
                            _letter!.closing!,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 15,
                              color: inkColor,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _letter!.signature?.isNotEmpty == true
                              ? _letter!.signature!
                              : _letter!.senderDisplay.name,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: inkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Back to Envelope button
                  Center(
                    child: TextButton.icon(
                      onPressed: _closeBackToEnvelope,
                      icon: const Icon(Icons.arrow_back, size: 16, color: AppTheme.primary),
                      label: Text(
                        'খামে ফেরত যান',
                        style: GoogleFonts.hindSiliguri(
                          color: AppTheme.primary,
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
      ),
    ),
  ),
);
  }
}

// Custom Painter for Envelope triangular flap
class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8D7B8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFD4B886)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height * 0.55);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
