// ═══════════════════════════════════════════════════════════════════════════
// FIREBASE CONFIGURATION — Fill in your values from the Firebase Console
// ═══════════════════════════════════════════════════════════════════════════
// How to get these values:
//   1. Go to https://console.firebase.google.com
//   2. Open your project → Project Settings (gear icon)
//   3. Under "Your apps", click the Web app (</>)
//   4. Copy the firebaseConfig values below
// ═══════════════════════════════════════════════════════════════════════════

class FirebaseConfig {
  // ── WEB APP CREDENTIALS ────────────────────────────────────────────────
  // From Firebase Console → Project Settings → Your Apps → Web App
  static const String webApiKey = 'AIzaSyBDx8iJDxbA8nxLNu4gxqR31ZGx2HF83dw';
  static const String webAuthDomain = 'ai-orthodontic.firebaseapp.com';
  static const String webProjectId = 'ai-orthodontic';
  static const String webStorageBucket = 'ai-orthodontic.firebasestorage.app';
  static const String webMessagingSenderId = '111852389426';
  static const String webAppId = '1:111852389426:web:7c3147bfff387a45bc682b';
  static const String webMeasurementId = 'YOUR_MEASUREMENT_ID'; // optional

  // ── ANDROID APP CREDENTIALS ────────────────────────────────────────────
  // From google-services.json (placed in android/app/)
  static const String androidPackageName = 'com.yourcompany.aiorthodontic';
  static const String androidAppId = '1:111852389426:android:09493627ce8bbc60bc682b';

  // ── IOS APP CREDENTIALS ────────────────────────────────────────────────
  // From GoogleService-Info.plist (placed in ios/Runner/)
  static const String iosBundleId = 'com.yourcompany.aiorthodontic';

  // ═══════════════════════════════════════════════════════════════════════
  // FEATURE FLAGS — Enable each after you've configured the service
  // ═══════════════════════════════════════════════════════════════════════

  /// Set to true after you've added Firebase config files and run
  /// "flutter pub get". Without this, the app runs in demo/mock mode.
  static const bool useFirebase = true;

  /// Set to true to use Firestore for cloud case storage.
  /// Requires [useFirebase] = true and Firestore enabled in console.
  static const bool useFirestore = true;

  /// Set to true to upload STL files to Firebase Storage.
  /// Requires [useFirebase] = true and Storage enabled in console.
  static const bool useFirebaseStorage = false;

  /// Set to true to enable "Sign in with Google".
  /// Requires Google Sign-In enabled in Firebase Auth console.
  static const bool enableGoogleSignIn = true;

  /// Web OAuth 2.0 Client ID for Google Sign-In on web.
  /// Get from: Firebase Console → Authentication → Sign-in method → Google
  ///           → Web SDK configuration → Web client ID
  /// Also add to web/index.html:
  ///   <meta name="google-signin-client-id" content="YOUR_WEB_CLIENT_ID">
  static const String webGoogleClientId = '111852389426-7j994qal14g7hkms97ie2obbuh2celkd.apps.googleusercontent.com'; // Fill in after enabling Google Sign-In

  // ── FIRESTORE COLLECTION NAMES ─────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String casesCollection = 'cases';
  static const String stlFilesCollection = 'stl_files';
  static const String analysesCollection = 'analyses';
  static const String effectivenessCollection = 'effectiveness_scores';
  static const String predictabilityCollection = 'predictability_results';
  static const String recommendationsCollection = 'recommendations';
  static const String validationCollection = 'validation_reports';

  // ── FIREBASE STORAGE PATHS ─────────────────────────────────────────────
  static const String stlStoragePath = 'stl_files';
  static const String profileImagesPath = 'profile_images';
  static const String reportsPath = 'reports';
}
