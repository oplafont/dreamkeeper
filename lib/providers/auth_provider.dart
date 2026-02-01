import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../services/logger_service.dart';

/// Authentication state provider
/// Manages user authentication state and provides reactive updates
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider() {
    _init();
  }

  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  String get displayName {
    if (_userProfile != null) {
      return _userProfile!['preferred_name'] ??
             _userProfile!['full_name'] ??
             _user?.email?.split('@').first ??
             'Dreamer';
    }
    return _user?.email?.split('@').first ?? 'Dreamer';
  }

  String? get email => _user?.email;

  void _init() {
    _user = _authService.currentUser;
    _authSubscription = _authService.authStateStream.listen(_handleAuthStateChange);

    if (_user != null) {
      _loadUserProfile();
    }
  }

  void _handleAuthStateChange(AuthState state) {
    log.debug('Auth state changed: ${state.event}');

    switch (state.event) {
      case AuthChangeEvent.signedIn:
        _user = state.session?.user;
        _loadUserProfile();
        break;
      case AuthChangeEvent.signedOut:
        _user = null;
        _userProfile = null;
        break;
      case AuthChangeEvent.userUpdated:
        _user = state.session?.user;
        _loadUserProfile();
        break;
      case AuthChangeEvent.tokenRefreshed:
        _user = state.session?.user;
        break;
      default:
        break;
    }

    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;

    try {
      _userProfile = await _authService.getUserProfile();
      notifyListeners();
    } catch (e) {
      log.warning('Failed to load user profile', e);
    }
  }

  /// Sign up a new user
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
    String? preferredName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        preferredName: preferredName,
      );
      return true;
    } catch (e) {
      _setError(_parseAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in an existing user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } catch (e) {
      _setError(_parseAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
    } catch (e) {
      _setError(_parseAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email: email);
      return true;
    } catch (e) {
      _setError(_parseAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? preferredName,
    String? timezone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateProfile(
        fullName: fullName,
        preferredName: preferredName,
        timezone: timezone,
      );
      await _loadUserProfile();
      return true;
    } catch (e) {
      _setError(_parseAuthError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user profile data
  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    log.error('Auth error: $error');
    notifyListeners();
  }

  String _parseAuthError(dynamic error) {
    final message = error.toString();

    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    }
    if (message.contains('Email not confirmed')) {
      return 'Please verify your email address';
    }
    if (message.contains('User already registered')) {
      return 'An account with this email already exists';
    }
    if (message.contains('Password should be')) {
      return 'Password must be at least 6 characters';
    }
    if (message.contains('network')) {
      return 'Network error. Please check your connection';
    }

    // Extract message from exception
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return 'An error occurred. Please try again';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
