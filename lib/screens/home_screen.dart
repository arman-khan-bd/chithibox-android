import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/chithi.dart';
import '../providers/auth_provider.dart';
import '../providers/chithi_provider.dart';
import '../theme/app_theme.dart';
import 'compose/compose_screen.dart';
import 'reader/chithi_reader_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final List<String> _boxes = ['inbox', 'sent', 'starred', 'archived'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chithiProv = context.read<ChithiProvider>();
      chithiProv.fetchLetters(box: 'inbox');
      chithiProv.loadCatalog();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final targetBox = _boxes[_tabController.index];
      context.read<ChithiProvider>().setActiveBox(targetBox);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<ChithiProvider>().fetchLetters(search: query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chithiProv = context.watch<ChithiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'চিঠি খুঁজুন...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  hintStyle: GoogleFonts.hindSiliguri(color: AppTheme.inkMuted),
                ),
                style: GoogleFonts.hindSiliguri(color: AppTheme.inkNavy),
                onChanged: _handleSearch,
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('📮', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'চিঠিবক্স',
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppTheme.inkNavy,
                        ),
                      ),
                      if (auth.user != null)
                        Text(
                          auth.user!.displayNameOrUsername,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: AppTheme.inkMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppTheme.inkNavy),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  chithiProv.fetchLetters();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppTheme.inkNavy),
            tooltip: 'প্রোফাইল সেটিংস',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.inkMuted,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ইনবক্স'),
                  if (chithiProv.unreadCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.postalRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${chithiProv.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'প্রেরিত'),
            const Tab(text: 'তারকাচিহ্নিত'),
            const Tab(text: 'সংরক্ষিত'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => chithiProv.fetchLetters(),
        color: AppTheme.primary,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLetterListView(chithiProv.inboxLetters, chithiProv, isInbox: true),
            _buildLetterListView(chithiProv.sentLetters, chithiProv, isSent: true),
            _buildLetterListView(chithiProv.starredLetters, chithiProv),
            _buildLetterListView(chithiProv.archivedLetters, chithiProv, isArchived: true),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final sent = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const ComposeScreen()),
          );
          if (sent == true && mounted) {
            _tabController.animateTo(1); // Switch to sent tab
            chithiProv.fetchLetters(box: 'sent');
          }
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_outlined),
        label: Text(
          'চিঠি লিখুন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildLetterListView(
    List<ChithiModel> letters,
    ChithiProvider chithiProv, {
    bool isInbox = false,
    bool isSent = false,
    bool isArchived = false,
  }) {
    if (chithiProv.isLoading && letters.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (letters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isInbox
                    ? '📭'
                    : isSent
                        ? '📤'
                        : isArchived
                            ? '📦'
                            : '⭐',
                style: const TextStyle(fontSize: 54),
              ),
              const SizedBox(height: 16),
              Text(
                isInbox
                    ? 'আপনার ইনবক্সে কোনো চিঠি নেই'
                    : isSent
                        ? 'আপনি এখনো কাউকে চিঠি পাঠাননি'
                        : isArchived
                            ? 'সংরক্ষণাগার খালি'
                            : 'কোনো তারকাচিহ্নিত চিঠি নেই',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.inkNavy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                isInbox
                    ? 'বন্ধুদের কাছে চিঠিবক্স লিংক শেয়ার করুন অথবা আপনি নিজেই কাউকে চিঠি লিখুন।'
                    : 'প্রিয়জনকে আপনার অনুভূতি জানিয়ে একটি সুন্দর ডাক চিঠি পাঠান।',
                style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppTheme.inkMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: letters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, index) {
        final letter = letters[index];
        return _buildLetterCard(letter, chithiProv, isInbox, isSent, isArchived);
      },
    );
  }

  Widget _buildLetterCard(
    ChithiModel letter,
    ChithiProvider chithiProv,
    bool isInbox,
    bool isSent,
    bool isArchived,
  ) {
    final dateFormat = DateFormat('dd MMM, yyyy');
    final formattedDate = dateFormat.format(letter.createdAt);
    final isUnread = isInbox && !letter.isRead;

    return Dismissible(
      key: Key('letter_${letter.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.postalRed,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (dir) async {
        return await showDialog<bool>(
              context: context,
              builder: (dCtx) => AlertDialog(
                title: const Text('চিঠিটি মুছে ফেলতে চান?'),
                content: const Text('চিঠিটি আপনার চিঠিবক্স থেকে মুছে যাবে।'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dCtx, false),
                    child: const Text('বাতিল'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.postalRed),
                    onPressed: () => Navigator.pop(dCtx, true),
                    child: const Text('মুছুন'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (dir) {
        chithiProv.deleteLetter(letter.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('চিঠিটি মুছে ফেলা হয়েছে')),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChithiReaderScreen(letterId: letter.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : AppTheme.parchmentCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnread ? AppTheme.primary.withOpacity(0.4) : AppTheme.parchmentBorder,
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isUnread ? 0.05 : 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stamp / Wax seal thumbnail preview
              Container(
                width: 44,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.amberLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentAmber.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    letter.stampDesign == 'tiger'
                        ? '🐅'
                        : letter.stampDesign == 'postbox'
                            ? '📮'
                            : '🌸',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title, Sender/Recipient, and Body Snippet
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isUnread) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            isSent
                                ? 'প্রতি: ${letter.recipientDisplay ?? "Recipient"}'
                                : letter.senderDisplay.name,
                            style: GoogleFonts.hindSiliguri(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              fontSize: 14,
                              color: isUnread ? AppTheme.inkNavy : AppTheme.inkNavy.withOpacity(0.85),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            color: AppTheme.inkSubtle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      letter.subject?.isNotEmpty == true
                          ? letter.subject!
                          : 'বিষয়হীন চিঠি',
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                        color: AppTheme.inkNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      letter.body.replaceAll('\n', ' ').trim(),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        color: AppTheme.inkMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Actions (Star & Archive / Recover)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      letter.isStarred ? Icons.star : Icons.star_border,
                      color: letter.isStarred ? AppTheme.accentAmber : AppTheme.inkSubtle,
                    ),
                    onPressed: () => chithiProv.toggleStar(letter.id),
                  ),
                  if (isArchived)
                    IconButton(
                      iconSize: 18,
                      padding: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(),
                      tooltip: 'ইনবক্সে ফিরিয়ে নিন',
                      icon: const Icon(Icons.unarchive_outlined, color: AppTheme.inkMuted),
                      onPressed: () => chithiProv.toggleArchive(letter.id, isArchived: false),
                    )
                  else if (isInbox)
                    IconButton(
                      iconSize: 18,
                      padding: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(),
                      tooltip: 'সংরক্ষণ করুন',
                      icon: const Icon(Icons.archive_outlined, color: AppTheme.inkMuted),
                      onPressed: () => chithiProv.toggleArchive(letter.id, isArchived: true),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
