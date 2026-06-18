import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters to access data safely from the UI
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Restore session on app startup
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _currentUser = await _authService.getUserDetails(firebaseUser.uid);
    }

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // 1. Sign Up Provider Method
Future<bool> signUp(String email, String password, String name, String phone) async {
  _setLoading(true);
  
  try {
    UserCredential? credential = await _authService.signUpWithEmailAndPassword(
      email, password, name, phone,
    );

    if (credential != null && credential.user != null) {
      // Fetch the newly created profile data from Firestore
      _currentUser = await _authService.getUserDetails(credential.user!.uid);
      _setLoading(false);
      notifyListeners(); // Tells UI to update
      return true;
    }
  } catch (e) {
    // THIS WILL PRINT THE EXACT ERROR REASON IN VS CODE!
    print("❌ PROVIDER SIGNUP ERROR: $e");
  }

  _setLoading(false);
  return false;
}

  // 2. Log In Provider Method
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    UserCredential? credential = await _authService.signInWithEmailAndPassword(email, password);
    
    if (credential != null && credential.user != null) {
      // Fetch user profile from Firestore
      _currentUser = await _authService.getUserDetails(credential.user!.uid);
      _setLoading(false);
      notifyListeners();
      return true;
    }
    
    _setLoading(false);
    return false;
  }

  // 3. Edit Profile Provider Method
  Future<bool> editProfile({
    required String name,
    required String phone,
    String location = '',
    String bio = '',
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);

    try {
      await _authService.updateUserProfile(
        userId: _currentUser!.userId,
        name: name,
        phone: phone,
        location: location,
        bio: bio,
      );
      _currentUser = UserModel(
        userId: _currentUser!.userId,
        name: name,
        email: _currentUser!.email,
        phone: phone,
        role: _currentUser!.role,
        location: location,
        bio: bio,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ PROVIDER EDIT PROFILE ERROR: $e");
      _setLoading(false);
      return false;
    }
  }

  // 5. Promote to Admin
  Future<bool> promoteToAdmin() async {
    if (_currentUser == null) return false;
    try {
      await _authService.promoteToAdmin(_currentUser!.userId);
      _currentUser = UserModel(
        userId: _currentUser!.userId,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        role: 'Admin',
        location: _currentUser!.location,
        bio: _currentUser!.bio,
      );
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ PROVIDER PROMOTE ADMIN ERROR: $e");
      return false;
    }
  }

  // 4. Log Out Provider Method
  Future<void> logout() async {
    _setLoading(true);
    await _authService.signOut();
    _currentUser = null;
    _isInitialized = false;
    _setLoading(false);
    notifyListeners();
  }

  // Helper method to toggle loading state safely
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}