import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient? _client;

  AuthService({SupabaseClient? client})
      : _client = client ?? _getSupabaseClient();

  static SupabaseClient? _getSupabaseClient() {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isConnected => _client != null && SupabaseConfig.isConfigured;

  User? get currentUser => _client?.auth.currentUser;

  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  /// Sign in using Email and Password
  Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (isConnected && _client != null) {
      return await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    }
    return null;
  }

  /// Sign up using Email and Password
  Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (isConnected && _client != null) {
      return await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
    }
    return null;
  }

  /// Sign in using Google OAuth (3rd-Party Provider)
  Future<bool> signInWithGoogle() async {
    if (isConnected && _client != null) {
      return await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.flutter://login-callback/',
      );
    }
    return false;
  }

  /// Sign out the current user
  Future<void> signOut() async {
    if (isConnected && _client != null) {
      await _client.auth.signOut();
    }
  }
}
