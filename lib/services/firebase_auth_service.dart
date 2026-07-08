import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../config/firebase_config.dart';

/// Wraps Firebase Authentication.
/// Only instantiate when [FirebaseConfig.useFirebase] is true.
class FirebaseAuthService {
  late final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // On web, clientId is required by the Google Identity Services library.
    clientId: kIsWeb && FirebaseConfig.webGoogleClientId.isNotEmpty
        ? FirebaseConfig.webGoogleClientId
        : null,
  );

  // ── STATE ────────────────────────────────────────────────────────────────

  fb.User? get currentFirebaseUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  // ── SIGN UP ──────────────────────────────────────────────────────────────

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? specialization,
    String? licenseNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);
      await credential.user?.sendEmailVerification();

      final uid = credential.user!.uid;
      return UserModel(
        uid: uid,
        email: email,
        name: name,
        role: role,
        specialization: specialization,
        licenseNumber: licenseNumber,
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on fb.FirebaseAuthException catch (e) {
      throw _authMessage(e);
    }
  }

  // ── SIGN IN ──────────────────────────────────────────────────────────────

  Future<fb.User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on fb.FirebaseAuthException catch (e) {
      throw _authMessage(e);
    }
  }

  // ── GOOGLE SIGN-IN ───────────────────────────────────────────────────────

  Future<fb.User?> signInWithGoogle() async {
    if (!FirebaseConfig.enableGoogleSignIn) {
      throw 'Google Sign-In is not enabled.';
    }
    try {
      if (kIsWeb) {
        // On web: use Firebase's signInWithPopup — avoids origin_mismatch
        // because Firebase Auth automatically allows localhost.
        final googleProvider = fb.GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        final userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        // On mobile: use google_sign_in package (standard flow)
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // user cancelled

        final googleAuth = await googleUser.authentication;
        final credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } on fb.FirebaseAuthException catch (e) {
      throw _authMessage(e);
    }
  }

  // ── SIGN OUT ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── PASSWORD RESET ───────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw _authMessage(e);
    }
  }

  // ── EMAIL VERIFICATION ───────────────────────────────────────────────────

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ── PROFILE UPDATE ───────────────────────────────────────────────────────

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  Future<void> updatePhotoUrl(String url) async {
    await _auth.currentUser?.updatePhotoURL(url);
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on fb.FirebaseAuthException catch (e) {
      throw _authMessage(e);
    }
  }

  // ── RE-AUTHENTICATE ──────────────────────────────────────────────────────

  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw 'No authenticated user.';
    try {
      final credential = fb.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      throw _authMessage(e);
    }
  }

  // ── DELETE ACCOUNT ───────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on fb.FirebaseAuthException catch (e) {
      throw _authMessage(e);
    }
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────

  String _authMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
