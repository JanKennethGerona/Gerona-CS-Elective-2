import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<AuthState>? _authSubscription;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuestMode = false;

  AuthProvider({AuthService? service})
      : _service = service ?? AuthService() {
    _currentUser = _service.currentUser;
    _listenToAuthChanges();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuestMode => _isGuestMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _listenToAuthChanges() {
    _authSubscription = _service.authStateChanges?.listen((data) {
      _currentUser = data.session?.user;
      if (_currentUser != null) {
        _isGuestMode = false;
      }
      notifyListeners();
    });
  }

  /// Sign in with Email and Password
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_service.isConnected) {
        // Fallback for demo testing
        _isGuestMode = true;
        _setLoading(false);
        return true;
      }

      final response = await _service.signInWithEmail(
        email: email,
        password: password,
      );

      _currentUser = response?.user;
      _isGuestMode = false;
      _setLoading(false);
      return _currentUser != null;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign up with Email and Password
  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_service.isConnected) {
        _isGuestMode = true;
        _setLoading(false);
        return true;
      }

      final response = await _service.signUpWithEmail(
        email: email,
        password: password,
      );

      _currentUser = response?.user;
      _setLoading(false);
      return _currentUser != null;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign in using Google OAuth (3rd-party provider)
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      if (!_service.isConnected) {
        _isGuestMode = true;
        _setLoading(false);
        return true;
      }

      final result = await _service.signInWithGoogle();
      _setLoading(false);
      return result;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Continue as Guest without signing in
  void continueAsGuest() {
    _isGuestMode = true;
    _clearError();
    notifyListeners();
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _service.signOut();
      _currentUser = null;
      _isGuestMode = false;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
