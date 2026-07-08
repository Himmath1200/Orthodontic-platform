import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/firebase_config.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/database_service.dart';
import '../services/mock_data_service.dart';

/// Unified auth provider.
/// When [FirebaseConfig.useFirebase] is false it behaves like the old
/// MockAuthProvider so the app still runs without Firebase configured.
/// Flip the flag and fill FirebaseConfig to switch to real auth.
class AuthProvider extends ChangeNotifier {
  // Firebase services — created lazily so they never touch
  // FirebaseAuth.instance / FirebaseFirestore.instance at startup
  // when Firebase is disabled (mock mode).
  FirebaseAuthService? _fbAuthInstance;
  FirebaseAuthService get _fbAuth =>
      _fbAuthInstance ??= FirebaseAuthService();

  FirestoreService? _firestoreInstance;
  FirestoreService get _firestore =>
      _firestoreInstance ??= FirestoreService();

  DatabaseService? _dbInstance;
  DatabaseService get _db => _dbInstance ??= DatabaseService();

  final MockDataService _mock = MockDataService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  StreamSubscription<List<UserModel>>? _doctorsStreamSub;

  // ── GETTERS ───────────────────────────────────────────────────────────────

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isFirebaseMode => FirebaseConfig.useFirebase;
  bool get isDoctor =>
      _currentUser?.role == UserRole.doctor;
  bool get isResearcher =>
      _currentUser?.role == UserRole.researcher;
  bool get isAdmin =>
      _currentUser?.role == UserRole.admin;

  // ── IN-MEMORY USER STORE (demo/mock mode) ─────────────────────────────────

  // Stores registered users by email so signIn() returns the real name/role.
  final Map<String, UserModel> _userStore = {};
  bool _storeReady = false;

  void _ensureStore() {
    if (_storeReady) return;
    _storeReady = true;
    final now = DateTime.now();
    final seeds = [
      UserModel(uid: 'demo_doctor_001', name: 'Dr. Sarah Johnson',
          email: 'doctor@test.com', role: UserRole.doctor,
          specialization: 'Orthodontist', createdAt: now, updatedAt: now),
      UserModel(uid: 'demo_doctor_002', name: 'Dr. Michael Chen',
          email: 'chen@clinic.com', role: UserRole.doctor,
          specialization: 'Pedodontist', createdAt: now, updatedAt: now),
      UserModel(uid: 'demo_doctor_003', name: 'Dr. Priya Sharma',
          email: 'priya@clinic.com', role: UserRole.doctor,
          specialization: 'General Dentist', createdAt: now, updatedAt: now),
      UserModel(uid: 'demo_researcher_001', name: 'Dr. Arjun Nair',
          email: 'research@test.com', role: UserRole.researcher,
          createdAt: now, updatedAt: now),
    ];
    for (final u in seeds) {
      _userStore[u.email.toLowerCase()] = u;
    }
  }

  /// All registered doctors — used by PatientProvider to populate the picker.
  List<UserModel> get registeredDoctors {
    _ensureStore();
    return _userStore.values.where((u) => u.role == UserRole.doctor).toList();
  }

  // ── INIT ──────────────────────────────────────────────────────────────────

  /// Call once at app startup.
  void init() {
    _ensureStore();
    if (!FirebaseConfig.useFirebase) {
      // Demo mode — user must sign in manually
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      return;
    }

    // Listen to Firebase auth state
    _fbAuth.authStateChanges.listen((fbUser) async {
      if (fbUser != null) {
        await _loadUserProfile(fbUser.uid);
        await _loadDoctorsFromPrefs(); // fast: restores cross-session doctors
        _startDoctorsStream();         // live: updates from Firestore (if enabled)
        _isAuthenticated = true;
      } else {
        _stopDoctorsStream();
        _currentUser = null;
        _isAuthenticated = false;
      }
      notifyListeners();
    });
  }

  // ── SIGN UP ───────────────────────────────────────────────────────────────

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? specialization,
    String? licenseNumber,
  }) async {
    _setLoading(true);

    if (!FirebaseConfig.useFirebase) {
      await Future.delayed(const Duration(milliseconds: 700));
      _ensureStore();
      final newUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        role: role,
        specialization: specialization,
        licenseNumber: licenseNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _userStore[email.toLowerCase().trim()] = newUser;
      _currentUser = newUser;
      _isAuthenticated = true;
      _setLoading(false);
      notifyListeners(); // triggers ProxyProvider to sync doctors list
      return true;
    }

    try {
      final user = await _fbAuth.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
        specialization: specialization,
        licenseNumber: licenseNumber,
      );

      // Save to Firestore + SQLite
      if (FirebaseConfig.useFirestore) {
        await _firestore.createUser(user);
      }
      await _db.upsertUser(user);

      // Keep in-memory store and persist for cross-session visibility
      _ensureStore();
      _userStore[email.toLowerCase().trim()] = user;
      if (role == UserRole.doctor) {
        _saveDoctorToPrefs(user); // researcher sees this doctor after logout/login
      }

      _currentUser = user;
      _isAuthenticated = true;
      _setLoading(false);
      notifyListeners(); // triggers ProxyProvider to sync doctors list
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── SIGN IN ───────────────────────────────────────────────────────────────

  Future<bool> signIn({
    required String email,
    required String password,
    UserRole mockRole = UserRole.doctor,
    String? mockName,
  }) async {
    _setLoading(true);

    if (!FirebaseConfig.useFirebase) {
      await Future.delayed(const Duration(milliseconds: 700));
      _ensureStore();
      // Look up actual registered user first
      final stored = _userStore[email.toLowerCase().trim()];
      if (stored != null) {
        _currentUser = stored;
      } else {
        // First-time sign-in for this email — create and persist
        final defaultName = mockRole == UserRole.researcher ? 'Demo Researcher' : 'Dr. Demo User';
        final newUser = UserModel(
          uid: 'user_${mockRole.name}_${DateTime.now().millisecondsSinceEpoch}',
          name: mockName ?? defaultName,
          email: email,
          role: mockRole,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _userStore[email.toLowerCase().trim()] = newUser;
        _currentUser = newUser;
      }
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    }

    try {
      final fbUser = await _fbAuth.signInWithEmail(
        email: email,
        password: password,
      );
      await _loadUserProfile(fbUser.uid);
      _startDoctorsStream();
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── GOOGLE SIGN IN ────────────────────────────────────────────────────────

  /// Demo Google sign-in that always uses in-memory store, regardless of Firebase mode.
  /// Used as a fallback when real Google Sign-In is not yet configured on this platform.
  Future<bool> signInDemoGoogle({required UserRole role}) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 500));
    _ensureStore();
    final name = role == UserRole.researcher ? 'Demo Researcher' : 'Dr. Demo User';
    final email = role == UserRole.researcher
        ? 'researcher@google.demo'
        : 'doctor@google.demo';
    final uid = role == UserRole.researcher
        ? 'google_demo_researcher'
        : 'google_demo_doctor';
    _currentUser = _userStore.putIfAbsent(
      email,
      () => UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    _isAuthenticated = true;
    _setLoading(false);
    return true;
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);

    if (!FirebaseConfig.useFirebase || !FirebaseConfig.enableGoogleSignIn) {
      _setError('google_not_configured');
      return false;
    }

    try {
      final fbUser = await _fbAuth.signInWithGoogle();
      if (fbUser == null) {
        _setLoading(false);
        return false;
      }

      // Check if user profile exists; create if new
      UserModel? existingUser;
      if (FirebaseConfig.useFirestore) {
        existingUser = await _firestore.getUser(fbUser.uid);
      } else {
        existingUser = await _db.getUserById(fbUser.uid);
      }

      if (existingUser == null) {
        final newUser = UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName ?? 'User',
          role: UserRole.doctor,
          profileImageUrl: fbUser.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        if (FirebaseConfig.useFirestore) {
          await _firestore.createUser(newUser);
        }
        await _db.upsertUser(newUser);
        _ensureStore();
        _userStore[(fbUser.email ?? '').toLowerCase()] = newUser;
        _currentUser = newUser;
      } else {
        _ensureStore();
        _userStore[(fbUser.email ?? '').toLowerCase()] = existingUser;
        _currentUser = existingUser;
      }

      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── SIGN OUT ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _setLoading(true);
    if (FirebaseConfig.useFirebase) {
      await _fbAuth.signOut();
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
    }
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    _setLoading(false);
  }

  // ── FORGOT PASSWORD ────────────────────────────────────────────────────────

  bool _isFirebaseMockMode = false;
  bool get isFirebaseMockMode => _isFirebaseMockMode;

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    if (!FirebaseConfig.useFirebase) {
      await Future.delayed(const Duration(milliseconds: 800));
      _isFirebaseMockMode = true;
      _setLoading(false);
      return true;
    }
    _isFirebaseMockMode = false;
    try {
      await _fbAuth.sendPasswordReset(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── UPDATE PROFILE ────────────────────────────────────────────────────────

  Future<bool> updateProfile({
    String? name,
    String? profileImageUrl,
    String? specialization,
    String? licenseNumber,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);

    try {
      final updated = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        name: name ?? _currentUser!.name,
        role: _currentUser!.role,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        specialization: specialization ?? _currentUser!.specialization,
        licenseNumber: licenseNumber ?? _currentUser!.licenseNumber,
        isEmailVerified: _currentUser!.isEmailVerified,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );

      if (FirebaseConfig.useFirebase) {
        if (name != null) await _fbAuth.updateDisplayName(name);
        if (profileImageUrl != null) await _fbAuth.updatePhotoUrl(profileImageUrl);
        if (FirebaseConfig.useFirestore) await _firestore.updateUser(updated);
      }
      await _db.upsertUser(updated);

      _currentUser = updated;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── EMAIL VERIFICATION ────────────────────────────────────────────────────

  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    if (!FirebaseConfig.useFirebase) {
      await Future.delayed(const Duration(milliseconds: 600));
      _setLoading(false);
      return true;
    }
    try {
      await _fbAuth.sendEmailVerification();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── DELETE ACCOUNT ────────────────────────────────────────────────────────

  Future<bool> deleteAccount() async {
    _setLoading(true);
    if (!FirebaseConfig.useFirebase) {
      await Future.delayed(const Duration(milliseconds: 800));
      _currentUser = null;
      _isAuthenticated = false;
      _setLoading(false);
      return true;
    }
    try {
      final uid = _currentUser?.uid;
      await _fbAuth.deleteAccount();
      if (uid != null) {
        if (FirebaseConfig.useFirestore) await _firestore.deleteUser(uid);
        await _db.deleteUser(uid);
      }
      _currentUser = null;
      _isAuthenticated = false;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  Future<void> _loadUserProfile(String uid) async {
    // Try SQLite first (offline-first), then Firestore
    UserModel? user = await _db.getUserById(uid);

    if (user == null && FirebaseConfig.useFirestore) {
      user = await _firestore.getUser(uid);
      if (user != null) await _db.upsertUser(user);
    }

    _currentUser = user;

    // Persist any doctor profile so the researcher's picker survives logout/login
    if (user?.role == UserRole.doctor) {
      _saveDoctorToPrefs(user!);
    }
  }

  // ── SHARED PREFS PERSISTENCE FOR DOCTORS ──────────────────────────────────

  static const _prefsKey = 'registered_doctors_v1';

  /// Saves a doctor to localStorage (SharedPreferences) so the researcher
  /// picker stays populated after logout/login without requiring Firestore.
  Future<void> _saveDoctorToPrefs(UserModel doctor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      final List<dynamic> list = raw != null ? jsonDecode(raw) : [];
      list.removeWhere((d) => d['uid'] == doctor.uid);
      list.add({
        'uid': doctor.uid,
        'name': doctor.name,
        'email': doctor.email,
        'specialization': doctor.specialization ?? 'Orthodontist',
      });
      await prefs.setString(_prefsKey, jsonEncode(list));
    } catch (_) {}
  }

  /// Loads all previously saved doctors from localStorage into [_userStore].
  /// Called on login so the researcher sees doctors from past sessions.
  Future<void> _loadDoctorsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final List<dynamic> list = jsonDecode(raw);
      _ensureStore();
      final now = DateTime.now();
      for (final d in list) {
        final email = (d['email'] as String).toLowerCase();
        _userStore[email] = UserModel(
          uid: d['uid'] as String,
          name: d['name'] as String,
          email: d['email'] as String,
          role: UserRole.doctor,
          specialization: d['specialization'] as String?,
          createdAt: now,
          updatedAt: now,
        );
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Starts a real-time Firestore stream that keeps the doctor list live.
  /// Fires immediately with current doctors, then again whenever any doctor
  /// signs up or updates their profile.
  void _startDoctorsStream() {
    if (!FirebaseConfig.useFirestore) return;
    _doctorsStreamSub?.cancel();
    _doctorsStreamSub = _firestore.watchDoctors().listen(
      (doctors) {
        _ensureStore();
        for (final d in doctors) {
          _userStore[d.email.toLowerCase()] = d;
          _saveDoctorToPrefs(d); // persist so they survive logout/login
        }
        notifyListeners(); // triggers ProxyProvider → PatientProvider.syncDoctors
      },
      onError: (_) {}, // non-fatal — falls back to prefs/seeded doctors
    );
  }

  void _stopDoctorsStream() {
    _doctorsStreamSub?.cancel();
    _doctorsStreamSub = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
