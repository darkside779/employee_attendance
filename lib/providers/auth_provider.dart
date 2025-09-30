// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/firebase_service.dart';
import '../core/constants/firebase_constants.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  User? _currentUser;
  UserModel? _currentUserModel;
  bool _isLoading = false;
  String? _errorMessage;
  // Getters
  User? get currentUser => _currentUser;
  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    try {
      if (_firebaseService.isInitialized) {
        _firebaseService.authStateChanges.listen((User? user) {
          _currentUser = user;
          if (user != null) {
            _loadUserModel(user.uid);
          } else {
            _currentUserModel = null;
          }
          notifyListeners();
        });
      } else {
        // Firebase not initialized - set up demo mode or handle gracefully
        _currentUser = null;
        _currentUserModel = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize authentication: $e';
      notifyListeners();
    }
  }

  // Load user model from Firestore
  Future<void> _loadUserModel(String userId) async {
    try {
      if (_firebaseService.isInitialized) {
        // Load from Firestore
        final doc = await _firebaseService.firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(userId)
            .get();
            
        if (doc.exists) {
          _currentUserModel = UserModel.fromFirestore(doc);
        } else {
          // Create default user if document doesn't exist
          _currentUserModel = UserModel(
            id: userId,
            name: _currentUser?.displayName ?? 'User',
            email: _currentUser?.email ?? '',
            role: 'accounting',
            department: 'Finance',
            permissions: ['view_employees', 'manage_attendance', 'generate_reports'],
            isActive: true,
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );
        }
      } else {
        // Fallback mock user for when Firebase is not initialized
        _currentUserModel = UserModel(
          id: userId,
          name: _currentUser?.displayName ?? 'User',
          email: _currentUser?.email ?? '',
          role: 'accounting',
          department: 'Finance',
          permissions: ['view_employees', 'manage_attendance', 'generate_reports'],
          isActive: true,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to load user data: $e');
      _errorMessage = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _firebaseService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (credential?.user != null) {
        _currentUser = credential!.user;
        await _loadUserModel(_currentUser!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create user with email and password and save to Firestore
  Future<bool> createUserWithEmailAndPassword(String email, String password, String name, [String role = 'accounting']) async {
    try {
      _setLoading(true);
      _clearError();

      // 1. Create Firebase Auth user
      final credential = await _firebaseService.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (credential?.user != null) {
        final user = credential!.user!;
        
        // 2. Set display name in Firebase Auth
        await user.updateDisplayName(name);
        
        // 3. Create UserModel document in Firestore
        final userModel = UserModel(
          id: user.uid,
          name: name,
          email: email,
          role: role,
          department: role == 'admin' ? 'Administration' : 'Finance',
          permissions: role == 'admin' 
              ? ['manage_users', 'manage_employees', 'manage_attendance', 'generate_reports', 'system_settings']
              : ['view_employees', 'manage_attendance', 'generate_reports'],
          lastLogin: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
        );
        
        // 4. Save to Firestore users collection
        await _firebaseService.firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toMap());
        
        // 5. Load the user model
        await _loadUserModel(user.uid);
        
        print('✅ User created successfully: ${userModel.name} (${userModel.role})');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create user: $e';
      print('❌ User creation failed: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      await _firebaseService.signOut();
      _currentUser = null;
      _currentUserModel = null;
      _clearError();
      return true;
    } catch (e) {
      _setError('Sign out failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create user account
  Future<bool> createUserAccount({
    required String email,
    required String password,
    required String name,
    required String role,
    required String department,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _firebaseService.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (credential?.user != null) {
        final user = credential!.user!;
        
        // Create user model in Firestore
        final userModel = UserModel(
          id: user.uid,
          role: role,
          email: email,
          name: name,
          permissions: _getDefaultPermissions(role),
          lastLogin: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          department: department,
        );

        await _firebaseService.createUser(userModel);
        _currentUser = user;
        _currentUserModel = userModel;
        
        return true;
      }
      return false;
    } catch (e) {
      _setError('Account creation failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firebaseService.resetPassword(email);
      return true;
    } catch (e) {
      _setError('Password reset failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      _setLoading(true);
      _clearError();

      await _firebaseService.updateUser(updatedUser);
      _currentUserModel = updatedUser;
      
      return true;
    } catch (e) {
      _setError('Profile update failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if user has permission
  bool hasPermission(String permission) {
    if (_currentUserModel == null) return false;
    return _currentUserModel!.hasPermission(permission);
  }

  // Check if user is admin
  bool get isAdmin => _currentUserModel?.isAdmin ?? false;

  // Check if user is accounting
  bool get isAccounting => _currentUserModel?.isAccounting ?? false;

  // Get default permissions for role
  List<String> _getDefaultPermissions(String role) {
    switch (role) {
      case 'admin':
        return [
          'manage_employees',
          'view_reports',
          'manage_users',
          'system_settings',
          'export_data',
        ];
      case 'accounting':
        return [
          'view_attendance',
          'calculate_salary',
          'generate_reports',
          'export_payroll',
        ];
      default:
        return [];
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

}
