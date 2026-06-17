import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Sign Up with Email & Password
  Future<UserCredential?> signUpWithEmailAndPassword(
    String email, 
    String password, 
    String name, 
    String phone,
  ) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;

      if (user != null) {
        // Create a new UserModel instance
        UserModel newUser = UserModel(
          userId: user.uid,
          name: name,
          email: email,
          phone: phone,
          role: 'Community Member', // Default fallback role
        );

        // Save user data to Firestore 'users' collection
        await _db.collection('users').doc(user.uid).set(newUser.toMap());
      }
      return result;
    } catch (e) {
      print("Error in Sign Up: ${e.toString()}");
      return null;
    }
  }

  // 2. Log In with Email & Password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print("Error in Sign In: ${e.toString()}");
      return null;
    }
  }

  // 3. Get Current User Data from Firestore
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching user details: ${e.toString()}");
      return null;
    }
  }

  // 4. Log Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: ${e.toString()}");
    }
  }
}