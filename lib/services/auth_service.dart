import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthService {
  final client = SupabaseService.instance.client;

  // Get current user
  User? get currentUser => client.auth.currentUser;

  // Get auth state stream
  Stream<AuthState> get authStateStream => client.auth.onAuthStateChange;

  /// Sign up a new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? preferredName,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? email.split('@')[0],
          'preferred_name': preferredName ?? fullName ?? email.split('@')[0],
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  /// Sign in an existing user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? preferredName,
    String? timezone,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (preferredName != null) updates['preferred_name'] = preferredName;

      final response = await client.auth.updateUser(
        UserAttributes(
          data: updates,
        ),
      );

      // Also update the user_profiles table
      if (currentUser != null) {
        final profileUpdates = <String, dynamic>{};
        if (fullName != null) profileUpdates['full_name'] = fullName;
        if (preferredName != null)
          profileUpdates['preferred_name'] = preferredName;
        if (timezone != null) profileUpdates['timezone'] = timezone;

        if (profileUpdates.isNotEmpty) {
          await client
              .from('user_profiles')
              .update(profileUpdates)
              .eq('id', currentUser!.id);
        }
      }

      return response;
    } catch (error) {
      throw Exception('Profile update failed: $error');
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
