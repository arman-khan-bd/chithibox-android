import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? error;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.error,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  static const String _tokenKey = 'chithi_auth_token';
  static const String _baseUrlKey = 'chithi_api_base_url';

  // Default base URL: points directly to the live domain
  static String get defaultBaseUrl => 'https://gb.e-bd.shop';

  String _baseUrl = defaultBaseUrl;
  String? _authToken;

  String get baseUrl => _baseUrl;
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    final savedUrl = prefs.getString(_baseUrlKey);
    // If empty or previously pointing to local dev/emulator, upgrade to live domain
    if (savedUrl == null || savedUrl.contains('localhost') || savedUrl.contains('10.0.2.2')) {
      _baseUrl = defaultBaseUrl;
      await prefs.setString(_baseUrlKey, _baseUrl);
    } else {
      _baseUrl = savedUrl;
    }
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, _baseUrl);
  }

  Future<void> setAuthToken(String? token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Generic Request Helper
  Future<ApiResponse<Map<String, dynamic>>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('$_baseUrl$path');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      http.Response response;
      final headers = _buildHeaders();

      if (method == 'GET') {
        response = await http.get(uri, headers: headers);
      } else if (method == 'POST') {
        response = await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      } else if (method == 'PATCH') {
        response = await http.patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      } else if (method == 'DELETE') {
        response = await http.delete(uri, headers: headers);
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      Map<String, dynamic> jsonResponse = {};
      try {
        jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        jsonResponse = {'raw': response.body};
      }

      final isSuccess = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          jsonResponse['success'] != false;

      return ApiResponse<Map<String, dynamic>>(
        success: isSuccess,
        message: jsonResponse['message']?.toString(),
        error: jsonResponse['error']?.toString() ??
            (isSuccess ? null : 'Request failed with status ${response.statusCode}'),
        data: jsonResponse,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'Network connection error: $e',
        statusCode: 0,
      );
    }
  }

  // --- Auth APIs ---

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String phone, String purpose) async {
    return _request('POST', '/api/v1/auth/otp/send', body: {
      'phone': phone,
      'purpose': purpose,
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp(
      String phone, String code, String purpose) async {
    return _request('POST', '/api/v1/auth/otp/verify', body: {
      'phone': phone,
      'code': code,
      'purpose': purpose,
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> loginWithPassword(
      String identifier, String password) async {
    final res = await _request('POST', '/api/v1/auth/login', body: {
      'identifier': identifier,
      'password': password,
    });
    if (res.success && res.data?['token'] != null) {
      await setAuthToken(res.data!['token'].toString());
    }
    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> loginWithOtp(
      String phone, String code) async {
    final res = await _request('POST', '/api/v1/auth/login', body: {
      'phone': phone,
      'code': code,
    });
    if (res.success && res.data?['token'] != null) {
      await setAuthToken(res.data!['token'].toString());
    }
    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String phone,
    required String code,
    String? displayName,
    String? password,
  }) async {
    final res = await _request('POST', '/api/v1/auth/register', body: {
      'phone': phone,
      'code': code,
      if (displayName != null) 'displayName': displayName,
      if (password != null) 'password': password,
    });
    if (res.success && res.data?['token'] != null) {
      await setAuthToken(res.data!['token'].toString());
    }
    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> getMe() async {
    return _request('GET', '/api/v1/auth/me');
  }

  Future<void> logout() async {
    try {
      await _request('POST', '/api/v1/auth/logout');
    } catch (_) {}
    await setAuthToken(null);
  }

  // --- Chithi APIs ---

  Future<ApiResponse<Map<String, dynamic>>> getLetters({
    String box = 'inbox',
    String? search,
  }) async {
    final query = <String, String>{'box': box};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    return _request('GET', '/api/v1/chithis', queryParams: query);
  }

  Future<ApiResponse<Map<String, dynamic>>> getLetterById(String id) async {
    return _request('GET', '/api/v1/chithis/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> sendLetter(Map<String, dynamic> data) async {
    return _request('POST', '/api/v1/chithis', body: data);
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleStar(String id) async {
    return _request('POST', '/api/v1/chithis/$id/star');
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleArchive(String id, {bool? isArchived}) async {
    return _request('POST', '/api/v1/chithis/$id/archive', body: {
      if (isArchived != null) 'isArchived': isArchived,
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteLetter(String id, {bool permanent = false}) async {
    return _request(
      'DELETE',
      '/api/v1/chithis/$id',
      queryParams: permanent ? {'permanent': 'true'} : null,
    );
  }

  // --- Catalog & Recipient APIs ---

  Future<ApiResponse<Map<String, dynamic>>> getCatalog() async {
    return _request('GET', '/api/v1/catalog');
  }

  Future<ApiResponse<Map<String, dynamic>>> checkRecipient(String query) async {
    return _request('GET', '/api/v1/recipient/check', queryParams: {'query': query});
  }

  // --- Profile & Settings APIs ---

  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? username,
    String? displayName,
    String? language,
  }) async {
    return _request('PATCH', '/api/v1/user/profile', body: {
      if (username != null) 'username': username,
      if (displayName != null) 'displayName': displayName,
      if (language != null) 'language': language,
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> updatePassword({
    String? currentPassword,
    required String newPassword,
    String actionType = 'change',
  }) async {
    return _request('POST', '/api/v1/user/password', body: {
      if (currentPassword != null) 'currentPassword': currentPassword,
      'newPassword': newPassword,
      'actionType': actionType,
    });
  }
}
