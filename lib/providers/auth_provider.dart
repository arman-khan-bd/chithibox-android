import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get isAuthenticated => apiService.isAuthenticated && _user != null;

  AuthProvider({required this.apiService});

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    if (!apiService.isAuthenticated) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiService.getMe();
      if (res.success && res.data?['user'] != null) {
        _user = UserModel.fromJson(res.data!['user'] as Map<String, dynamic>);
        _unreadCount = (res.data!['stats']?['unreadLetters'] as num?)?.toInt() ?? 0;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        await apiService.setAuthToken(null);
        _user = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithPassword(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await apiService.loginWithPassword(identifier, password);
    _isLoading = false;

    if (res.success && res.data?['user'] != null) {
      _user = UserModel.fromJson(res.data!['user'] as Map<String, dynamic>);
      notifyListeners();
      return true;
    } else {
      _errorMessage = res.error ?? 'Login failed. Please check credentials.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithOtp(String phone, String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await apiService.loginWithOtp(phone, code);
    _isLoading = false;

    if (res.success && res.data?['user'] != null) {
      _user = UserModel.fromJson(res.data!['user'] as Map<String, dynamic>);
      notifyListeners();
      return true;
    } else {
      _errorMessage = res.error ?? 'Invalid OTP code.';
      notifyListeners();
      return false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String phone, String purpose) async {
    return apiService.sendOtp(phone, purpose);
  }

  Future<bool> register({
    required String phone,
    required String code,
    String? displayName,
    String? password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await apiService.register(
      phone: phone,
      code: code,
      displayName: displayName,
      password: password,
    );
    _isLoading = false;

    if (res.success && res.data?['user'] != null) {
      _user = UserModel.fromJson(res.data!['user'] as Map<String, dynamic>);
      notifyListeners();
      return true;
    } else {
      _errorMessage = res.error ?? 'Registration failed.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await apiService.logout();
    _user = null;
    _unreadCount = 0;
    notifyListeners();
  }

  Future<bool> updateProfile({String? username, String? displayName, String? language}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await apiService.updateProfile(
      username: username,
      displayName: displayName,
      language: language,
    );
    _isLoading = false;

    if (res.success && res.data?['user'] != null) {
      _user = UserModel.fromJson(res.data!['user'] as Map<String, dynamic>);
      notifyListeners();
      return true;
    } else {
      _errorMessage = res.error ?? 'Failed to update profile.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({
    String? currentPassword,
    required String newPassword,
    String actionType = 'change',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await apiService.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      actionType: actionType,
    );
    _isLoading = false;

    if (res.success) {
      await checkAuthStatus();
      return true;
    } else {
      _errorMessage = res.error ?? 'Failed to update password.';
      notifyListeners();
      return false;
    }
  }

  Future<void> setCustomBaseUrl(String url) async {
    await apiService.setBaseUrl(url);
    notifyListeners();
  }
}
