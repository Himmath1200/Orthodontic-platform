import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';

/// Mock Auth Provider for Frontend Demo
/// Uses mock data instead of Firebase authentication
class MockAuthProvider extends ChangeNotifier {
  final MockDataService _mockDataService = MockDataService();

  late UserModel _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isDoctor => _currentUser.role == UserRole.doctor;
  bool get isResearcher => _currentUser.role == UserRole.researcher;
  bool get isAdmin => _currentUser.role == UserRole.admin;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize with mock user (for demo)
  void listenToAuthChanges() {
    // In demo mode, automatically authenticate
    _currentUser = _mockDataService.getDemoUser();
    _isAuthenticated = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Mock sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock successful signup
    _currentUser = UserModel(
      uid: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      profileImageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Mock sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // For demo, accept demo@orthodontic.com
    if (email == 'demo@orthodontic.com' && password == 'Demo@12345') {
      _currentUser = _mockDataService.getDemoUser();
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Invalid credentials. Try: demo@orthodontic.com / Demo@12345';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Mock sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isAuthenticated = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Mock forgot password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Mock update profile
  Future<bool> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = UserModel(
      uid: _currentUser.uid,
      name: name ?? _currentUser.name,
      email: _currentUser.email,
      role: _currentUser.role,
      profileImageUrl: profileImageUrl ?? _currentUser.profileImageUrl,
      createdAt: _currentUser.createdAt,
      updatedAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Mock verify email
  Future<bool> verifyEmail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Mock delete account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
