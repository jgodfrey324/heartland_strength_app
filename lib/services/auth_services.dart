// Handles Firebase Auth logic
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Helper for login or sign up error message
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      default:
        return 'Login or Sign up failed: ${e.message ?? 'Unknown error.'}';
    }
  }

  // Sign up user and save additional info to Firestore
  Future<(UserCredential?, String?)> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 2. Store additional info in Firestore
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email.trim(),
        'role': role, // "athlete" or "coach"
        'assignedProgramIds': [],
        'completedWorkouts': [],
        'teamIds': [],
        'createdAt': Timestamp.now(),
      });

      return (userCred, null);
    } on FirebaseAuthException catch (e) {
      return (null, _handleAuthError(e));
    } catch (e) {
      return (null, 'Unexpected error: $e');
    }
  }

  // Log in with email and password -- return either user credential or error message
  Future<(UserCredential?, String?)> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return (credential, null);
    } on FirebaseAuthException catch (e) {
      final errorMessage = _handleAuthError(e);
      return (null, errorMessage);
    } catch (e) {
      return (null, 'Unexpected error: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Fetch user data from store
  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = currentUser;

    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return doc.data();
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Return the current user's UID, or null if not logged in
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
