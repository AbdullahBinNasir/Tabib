import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userProfile;

  AuthProvider() {
    _user = _authService.currentUser;
    if (_user != null) {
      _loadUserProfile();
    }
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userProfile => _userProfile;

  bool get isAdmin => _userProfile?['role'] == 'admin';
  bool get isPharmacologist => _userProfile?['role'] == 'pharmacologist';

  /// Load user profile from Firestore
  Future<void> _loadUserProfile() async {
    try {
      _userProfile = await _authService.getUserProfile(_user!.uid);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Sign up new user
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String address,
    String? dateOfBirth,
  }) async {
    _setLoading(true);

    try {
      final userCredential = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        dateOfBirth: dateOfBirth,
      );
      _user = userCredential.user;
      await _loadUserProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Sign in existing user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final userCredential = await _authService.signIn(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      await _loadUserProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Update user profile details
  Future<void> updateUserProfile({
    required String fullName,
    required String email,
  }) async {
    _setLoading(true);

    try {
      await _authService.updateUserProfile(
        uid: _user!.uid,
        fullName: fullName,
        email: email,
      );

      _userProfile?['fullName'] = fullName;
      _userProfile?['email'] = email;

      await _user?.updateEmail(email);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void _setError(String errorMsg) {
    _error = errorMsg;
    _isLoading = false;
    notifyListeners();
  }
}
