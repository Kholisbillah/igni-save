import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../profile/data/models/user_profile_model.dart';

/// Authentication service using Firebase Auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get user profile stream
  Stream<UserProfile?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) debugPrint('AuthService: Attempting sign in...');
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Ensure user document exists
      if (result.user != null) {
        await _ensureUserDocument(result.user!);
      }

      debugPrint(
        'AuthService: Sign in successful for user: ${result.user?.uid}',
      );
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: FirebaseAuthException: ${e.code} - ${e.message}',
      );
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('AuthService: General error: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      if (kDebugMode) debugPrint('AuthService: Attempting sign up...');
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        await result.user!.updateDisplayName(username);
        await _createUserDocument(result.user!, username: username);
      }

      debugPrint(
        'AuthService: Sign up successful for user: ${result.user?.uid}',
      );
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: FirebaseAuthException: ${e.code} - ${e.message}',
      );
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('AuthService: General error: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('AuthService: Starting Google Sign-In');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('AuthService: User cancelled Google Sign-In');
        return null;
      }

      if (kDebugMode) debugPrint('AuthService: Google sign-in user obtained');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final result = await _auth.signInWithCredential(credential);

      if (result.user != null) {
        await _ensureUserDocument(result.user!);
      }

      debugPrint(
        'AuthService: Google Sign-In successful for user: ${result.user?.uid}',
      );
      return result;
    } catch (e) {
      debugPrint('AuthService: Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      debugPrint('AuthService: Signing out');
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      debugPrint('AuthService: Sign out successful');
    } catch (e) {
      debugPrint('AuthService: Sign out error: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);

      // Update Firestore document
      final updates = <String, dynamic>{};
      if (displayName != null) updates['username'] = displayName;
      if (photoURL != null) updates['photo_url'] = photoURL;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(User user, {String? username}) async {
    final userProfile = UserProfile.newUser(
      uid: user.uid,
      email: user.email ?? '',
      username: username ?? user.displayName,
      photoUrl: user.photoURL,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userProfile.toFirestore());
  }

  /// Ensure user document exists, create if not
  Future<void> _ensureUserDocument(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _createUserDocument(user);
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
