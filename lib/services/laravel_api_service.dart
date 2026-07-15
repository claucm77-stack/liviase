import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/app_config.dart';
import '../core/constants/app_roles.dart';

/// Service for interacting with Laravel API.
/// Provides authentication, session management, and data access.
class LaravelApiService {
  LaravelApiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.laravelApiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  // Token storage
  String? _token;

  /// Set the authentication token
  void setToken(String token) {
    _token = token;
  }

  /// Remove the authentication token
  void removeToken() {
    _token = null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Get common headers with optional auth
  Map<String, String> _headers({bool withAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = _decodeJson(response.body);
      final message = decoded is Map<String, dynamic>
          ? decoded['message'] ?? 'Error desconocido'
          : 'Error desconocido';
      throw ApiException(message, response.statusCode);
    }
    return _decodeJson(response.body);
  }

  dynamic _decodeJson(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  // ==================== AUTHENTICATION ====================

  /// Login user with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _handleResponse(response);
    final authResponse = AuthResponse.fromJson(data);
    _token = authResponse.token;
    return authResponse;
  }

  /// Register a new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? role,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (role != null) 'role': role,
      }),
    );

    final data = _handleResponse(response);
    final authResponse = AuthResponse.fromJson(data);
    _token = authResponse.token;
    return authResponse;
  }

  /// Logout current user
  Future<void> logout() async {
    if (!isAuthenticated) return;

    try {
      await _client.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: _headers(),
      );
    } finally {
      _token = null;
    }
  }

  /// Get current authenticated user
  Future<User> getCurrentUser() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: _headers(),
    );

    final data = _handleResponse(response);
    return User.fromJson(data);
  }

  /// Refresh authentication token
  Future<AuthResponse> refreshToken() async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: _headers(),
    );

    final data = _handleResponse(response);
    final authResponse = AuthResponse.fromJson(data);
    _token = authResponse.token;
    return authResponse;
  }

  // ==================== PASSWORD MANAGEMENT ====================

  /// Send password reset email
  Future<String> forgotPassword({required String email}) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/forgot'),
      headers: _headers(withAuth: false),
      body: jsonEncode({'email': email}),
    );

    final data = _handleResponse(response);
    return data['message'] ??
        'Si el correo existe, se enviará un enlace de recuperación';
  }

  /// Reset password with token
  Future<String> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/reset'),
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final data = _handleResponse(response);
    return data['message'] ?? 'Contraseña restablecida exitosamente';
  }

  /// Change password (requires current password)
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/password/change'),
      headers: _headers(),
      body: jsonEncode({
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      }),
    );

    final data = _handleResponse(response);
    _token = null; // Force re-login
    return data['message'] ?? 'Contraseña cambiada exitosamente';
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Get all active sessions
  Future<List<Session>> getSessions() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/auth/sessions'),
      headers: _headers(),
    );

    final data = _handleResponse(response);
    final sessions = data['sessions'] as List<dynamic>? ?? [];
    return sessions.map((s) => Session.fromJson(s)).toList();
  }

  /// Revoke a specific session
  Future<void> revokeSession(int tokenId) async {
    await _client.delete(
      Uri.parse('$_baseUrl/auth/sessions/$tokenId'),
      headers: _headers(),
    );
  }

  /// Revoke all sessions except current
  Future<void> revokeAllSessions() async {
    await _client.post(
      Uri.parse('$_baseUrl/auth/sessions/revoke-all'),
      headers: _headers(),
    );
  }

  // ==================== CONTENT API ====================

  /// Fetch contents from API
  Future<List<Map<String, dynamic>>> fetchContents({int perPage = 20}) async {
    final uri = Uri.parse('$_baseUrl/contents?per_page=$perPage');
    final response = await _client.get(uri, headers: _headers(withAuth: false));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al obtener contenidos: ${response.statusCode}');
    }

    final decoded = _decodeJson(response.body);
    if (decoded is! Map<String, dynamic>) return const [];

    final data = decoded['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  Future<List<MicrobusinessFieldDefinition>> fetchMicrobusinessFields() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/microbusiness-fields'),
      headers: _headers(withAuth: false),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al obtener campos de micronegocios: ${response.statusCode}',
      );
    }

    final decoded = _decodeJson(response.body);
    if (decoded is! Map<String, dynamic>) return const [];

    final data = decoded['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .map(MicrobusinessFieldDefinition.fromJson)
        .toList();
  }

  /// Dispose the client
  void dispose() {
    _client.close();
  }
}

// ==================== MODELS ====================

/// User model
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String roleDisplayName;
  final bool isActive;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roleDisplayName,
    required this.isActive,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final role = AppRoles.normalize(json['role'] as String?);
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: role,
      roleDisplayName:
          json['role_display_name'] as String? ?? AppRoles.label(role),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  bool get isAdmin => AppRoles.isAdminTi(role);
  bool get canManageUsers => AppRoles.canManageUsers(role);
}

class MicrobusinessFieldDefinition {
  const MicrobusinessFieldDefinition({
    required this.id,
    required this.name,
    required this.fieldType,
    required this.isRequired,
    required this.isFilterable,
    required this.sortOrder,
    required this.options,
  });

  final String id;
  final String name;
  final String fieldType;
  final bool isRequired;
  final bool isFilterable;
  final int sortOrder;
  final List<String> options;

  factory MicrobusinessFieldDefinition.fromJson(Map<String, dynamic> json) {
    final options = json['options'];
    return MicrobusinessFieldDefinition(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      fieldType: (json['field_type'] ?? 'text').toString(),
      isRequired: json['is_required'] == true,
      isFilterable: json['is_filterable'] == true,
      sortOrder: int.tryParse((json['sort_order'] ?? 0).toString()) ?? 0,
      options: options is List ? options.map((e) => e.toString()).toList() : [],
    );
  }
}

/// Authentication response
class AuthResponse {
  final String message;
  final User user;
  final String token;
  final DateTime? expiresAt;

  AuthResponse({
    required this.message,
    required this.user,
    required this.token,
    this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String? ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
    );
  }
}

/// Session model
class Session {
  final int id;
  final String name;
  final List<String> abilities;
  final DateTime? lastUsedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;

  Session({
    required this.id,
    required this.name,
    required this.abilities,
    this.lastUsedAt,
    this.expiresAt,
    required this.createdAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      abilities: (json['abilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lastUsedAt: json['last_used_at'] != null
          ? DateTime.tryParse(json['last_used_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

/// API Exception
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidationError => statusCode == 422;
  bool get isRateLimited => statusCode == 429;
}
