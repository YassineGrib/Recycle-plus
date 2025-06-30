import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import 'package:flutter/widgets.dart';

class AuthProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Initialize auth state from shared preferences
  Future<void> initializeAuth() async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      
      if (userId != null) {
        _currentUser = await _dataService.getUserById(userId);
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize authentication';
      print('Auth initialization error: $e');
    }

    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Login with email and password (simplified for demo)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // In a real app, you would validate password
      // For demo purposes, we'll just check if user exists
      final user = await _dataService.getUserByEmail(email);
      
      if (user != null && user.isActive) {
        _currentUser = user;
        
        // Save user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_id', user.id);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or user not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user (simplified for demo)
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required UserRole role,
    required String location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if user already exists
      final existingUser = await _dataService.getUserByEmail(email);
      if (existingUser != null) {
        _errorMessage = 'User with this email already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // In a real app, you would save to backend
      // For demo, we'll create a user object but not persist it
      final newUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        role: role,
        location: location,
        createdAt: DateTime.now(),
      );

      _currentUser = newUser;
      
      // Save user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', newUser.id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'Logout failed: ${e.toString()}';
      print('Logout error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? location,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        location: location ?? _currentUser!.location,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profile update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if current user has specific role
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  // Check if current user is admin
  bool get isAdmin => hasRole(UserRole.admin);
  
  // Check if current user is seller
  bool get isSeller => hasRole(UserRole.seller);
  
  // Check if current user is buyer
  bool get isBuyer => hasRole(UserRole.buyer);
}
