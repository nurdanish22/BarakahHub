import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;

  // Getters to access data safely from the UI
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

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

  // 3. Log Out Provider Method
  Future<void> logout() async {
    _setLoading(true);
    await _authService.signOut();
    _currentUser = null;
    _setLoading(false);
    notifyListeners();
  }

  // Helper method to toggle loading state safely
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}