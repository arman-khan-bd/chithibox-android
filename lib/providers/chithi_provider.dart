import 'package:flutter/material.dart';
import '../models/chithi.dart';
import '../models/catalog.dart';
import '../services/api_service.dart';

class ChithiProvider extends ChangeNotifier {
  final ApiService apiService;

  List<ChithiModel> _inboxLetters = [];
  List<ChithiModel> _sentLetters = [];
  List<ChithiModel> _starredLetters = [];
  List<ChithiModel> _archivedLetters = [];

  CatalogModel? _catalog;
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;
  String _activeBox = 'inbox';

  List<ChithiModel> get inboxLetters => _inboxLetters;
  List<ChithiModel> get sentLetters => _sentLetters;
  List<ChithiModel> get starredLetters => _starredLetters;
  List<ChithiModel> get archivedLetters => _archivedLetters;

  List<ChithiModel> get currentLetters {
    switch (_activeBox) {
      case 'sent':
        return _sentLetters;
      case 'starred':
        return _starredLetters;
      case 'archived':
        return _archivedLetters;
      default:
        return _inboxLetters;
    }
  }

  CatalogModel? get catalog => _catalog;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  String get activeBox => _activeBox;

  ChithiProvider({required this.apiService});

  void setActiveBox(String box) {
    if (_activeBox != box) {
      _activeBox = box;
      notifyListeners();
      fetchLetters(box: box);
    }
  }

  Future<void> loadCatalog() async {
    if (_catalog != null) return;
    try {
      final res = await apiService.getCatalog();
      if (res.success && res.data?['catalog'] != null) {
        _catalog = CatalogModel.fromJson(res.data!['catalog'] as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchLetters({String? box, String? search}) async {
    final targetBox = box ?? _activeBox;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiService.getLetters(box: targetBox, search: search);
      _isLoading = false;

      if (res.success && res.data?['letters'] != null) {
        final list = (res.data!['letters'] as List)
            .map((item) => ChithiModel.fromJson(item as Map<String, dynamic>))
            .toList();

        if (targetBox == 'sent') {
          _sentLetters = list;
        } else if (targetBox == 'starred') {
          _starredLetters = list;
        } else if (targetBox == 'archived') {
          _archivedLetters = list;
        } else {
          _inboxLetters = list;
          _unreadCount = (res.data!['unreadCount'] as num?)?.toInt() ??
              list.where((l) => !l.isRead).length;
        }
      } else {
        _errorMessage = res.error ?? 'Failed to load letters';
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<ChithiModel?> getLetterDetails(String id) async {
    final res = await apiService.getLetterById(id);
    if (res.success && res.data?['letter'] != null) {
      final letter = ChithiModel.fromJson(res.data!['letter'] as Map<String, dynamic>);

      // Update in local lists if present
      _updateLetterLocally(letter);
      notifyListeners();
      return letter;
    }
    return null;
  }

  Future<ApiResponse<Map<String, dynamic>>> sendLetter(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final res = await apiService.sendLetter(data);
    _isLoading = false;

    if (res.success) {
      // Refresh sent box
      fetchLetters(box: 'sent');
    }
    notifyListeners();
    return res;
  }

  Future<bool> toggleStar(String id) async {
    final res = await apiService.toggleStar(id);
    if (res.success && res.data?['isStarred'] != null) {
      final isStarred = res.data!['isStarred'] == true;

      // Update in all local lists
      _updateStarLocally(id, isStarred);
      notifyListeners();
      return isStarred;
    }
    return false;
  }

  Future<bool> toggleArchive(String id, {bool? isArchived}) async {
    final res = await apiService.toggleArchive(id, isArchived: isArchived);
    if (res.success && res.data?['isArchived'] != null) {
      final archived = res.data!['isArchived'] == true;

      if (archived) {
        // Move from inbox to archived
        final match = _inboxLetters.where((l) => l.id == id).toList();
        if (match.isNotEmpty) {
          _inboxLetters.removeWhere((l) => l.id == id);
          _archivedLetters.insert(0, match.first.copyWith(isArchived: true));
        }
      } else {
        // Recover from archived to inbox
        final match = _archivedLetters.where((l) => l.id == id).toList();
        if (match.isNotEmpty) {
          _archivedLetters.removeWhere((l) => l.id == id);
          _inboxLetters.insert(0, match.first.copyWith(isArchived: false));
        }
      }
      notifyListeners();
      return archived;
    }
    return false;
  }

  Future<bool> deleteLetter(String id, {bool permanent = false}) async {
    final res = await apiService.deleteLetter(id, permanent: permanent);
    if (res.success) {
      _inboxLetters.removeWhere((l) => l.id == id);
      _sentLetters.removeWhere((l) => l.id == id);
      _starredLetters.removeWhere((l) => l.id == id);
      _archivedLetters.removeWhere((l) => l.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<ApiResponse<Map<String, dynamic>>> checkRecipient(String query) async {
    return apiService.checkRecipient(query);
  }

  void _updateLetterLocally(ChithiModel updated) {
    void replaceInList(List<ChithiModel> list) {
      final idx = list.indexWhere((l) => l.id == updated.id);
      if (idx != -1) {
        list[idx] = updated;
      }
    }

    replaceInList(_inboxLetters);
    replaceInList(_sentLetters);
    replaceInList(_starredLetters);
    replaceInList(_archivedLetters);
  }

  void _updateStarLocally(String id, bool isStarred) {
    void update(List<ChithiModel> list) {
      final idx = list.indexWhere((l) => l.id == id);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(isStarred: isStarred);
      }
    }

    update(_inboxLetters);
    update(_sentLetters);
    update(_archivedLetters);

    if (isStarred) {
      final found = [..._inboxLetters, ..._sentLetters].where((l) => l.id == id).toList();
      if (found.isNotEmpty && !_starredLetters.any((l) => l.id == id)) {
        _starredLetters.insert(0, found.first.copyWith(isStarred: true));
      }
    } else {
      _starredLetters.removeWhere((l) => l.id == id);
    }
  }
}
