import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// A service class for handling Firebase Authentication and user data.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream that notifies about changes to the user's sign-in state.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in user.
  User? get currentUser => _auth.currentUser;

  /// Signs in a user with the given email and password.
  /// Returns null on success, or an error message string on failure.
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Error signing in: ${e.code}',
        name: 'com.example.griefey.auth',
        error: e,
      );
      return _getAuthErrorMessage(e.code);
    }
  }

  /// Creates a new user with the given email, password, and name.
  /// Stores additional user information in Firestore.
  /// Returns null on success, or an error message string on failure.
  Future<String?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Create the user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // 2. Update the user's display name in Firebase Auth
        await user.updateDisplayName(name);

        // 3. Create the user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': Timestamp.now(),
          'isAdmin': false,
          'uid': user.uid,
        });
      }
      return null; // Success
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Error signing up: ${e.code}',
        name: 'com.example.griefey.auth',
        error: e,
      );
      return _getAuthErrorMessage(e.code);
    } catch (e) {
      developer.log(
        'An unexpected error occurred during sign-up',
        name: 'com.example.griefey.auth',
        error: e,
      );
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      developer.log(
        'Error signing out',
        name: 'com.example.griefey.auth',
        error: e,
      );
      // In a real-world app, you might want to notify the user
      // but for sign-out, it's often fine to fail silently.
    }
  }

  /// Converts Firebase Auth error codes into user-friendly messages.
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email. Please check the email or sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'An unexpected authentication error occurred: $code';
    }
  }
}
