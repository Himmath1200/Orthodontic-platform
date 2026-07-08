# AI Orthodontic Platform

A **Flutter web application** for orthodontic case management, clinical analysis, and patient reporting. Researchers upload patient files and assign them to doctors; doctors review cases, generate clinical PDF reports, and deliver them to patients via Email or WhatsApp.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.44 · Dart · Material Design 3 |
| State Management | Provider v6.1 (ChangeNotifier + ProxyProvider) |
| Authentication | Firebase Auth — Email/Password + Google Sign-In (popup) |
| Cloud Database | Cloud Firestore (real-time streams) |
| Local Persistence | SharedPreferences (browser localStorage on web) |
| Local DB | SQLite via `sqflite` (mobile/desktop only — no-op on web) |
| File Picking | `file_picker` — real system file explorer |
| PDF Generation | `pdf` package (pure Dart, works on web) |
| Web APIs | `dart:html` — blob downloads, mailto, WhatsApp links |
| Charts | `fl_chart` |

---

## User Roles

| Role | Portal | What they can do |
|---|---|---|
| **Researcher** | `/researcher` | Create patient records, upload STL / X-ray / photos, assign patients to doctors |
| **Doctor** | `/dashboard` | View assigned patients, upload STL files, write clinical analysis, generate & send PDF reports |
| **Admin** | `/dashboard` | Same as Doctor (admin screens planned) |

> Role enforcement is strict — a doctor account cannot log in through the Researcher tab and vice versa.

---

## Features

### Authentication
- Email / Password sign-up and login
- **Google Sign-In** on web via `signInWithPopup` (avoids origin_mismatch)
- Role-based tab selection on login screen (Doctor / Researcher)
- Role enforcement: wrong-tab login is blocked with an error
- Password reset via email
- Email verification on sign-up
- Persistent auth state across page refreshes (Firebase Auth listener)

### Patient Management (Researcher)
- Create patient records with personal + clinical info (chief complaint, medical history, medications, allergies)
- Assign patients to a doctor from the live doctor picker
- Upload multiple files per patient (STL, OBJ, PLY, JPG, PNG, PDF, DICOM, ZIP)
- Files stored in-memory with actual bytes (viewable by doctor in same session)
- Real-time patient list with status filter (All / Pending / Assigned / In Progress / Completed)

### Doctor Dashboard
- Patients assigned to the logged-in doctor are listed automatically
- Quick actions: Upload STL, My Cases, New Case, Reports
- View full patient detail (clinical info, assigned files, notes)

### File Viewing (Doctor)
- Click any uploaded image (JPG/PNG) → opens a full-screen preview dialog
- Click any other file (STL, PDF, ZIP) → triggers browser download
- Files uploaded in the same session are highlighted in blue and are clickable

### STL / File Upload (Doctor)
- Navigate to **Upload STL** from the doctor dashboard
- Step 1: Select a patient from the assigned list
- Step 2: Browse files via the real system file explorer (STL, OBJ, PLY, JPG, PNG, PDF, DICOM)
- Step 3: Save — files are stored under the patient record and appear in their attached-files list

### Clinical Report Generation (Doctor)
- In patient detail view, fill in: Diagnosis, STL Analysis Findings, Treatment Plan, Recommendations
- Click **Generate Final Report** → renders a formatted report preview
- Click **Print PDF** → generates a real PDF and downloads it; also saves the PDF to the patient's record
- Generated PDF includes: header with clinic branding, patient info grid, colour-coded sections, doctor signature, page numbers

### Report Delivery
- **Send via Email** — generates PDF → downloads it → opens the system email client pre-filled with the patient's email, subject, and message body. Attach the downloaded PDF and send.
- **Send via WhatsApp** — enter the patient's mobile number (with country code, e.g. `919876543210`) → generates PDF → downloads it → opens WhatsApp Web to that number. A step-by-step instruction dialog guides the doctor to attach the PDF using the WhatsApp paperclip button.

### Doctor Picker (Cross-session)
- New doctor accounts appear in the researcher's doctor picker immediately (same session)
- Three-layer persistence: in-memory → SharedPreferences (localStorage) → Firestore real-time stream
- Doctor list survives logout/login and page refresh

---

## Project Structure

```
lib/
├── main.dart                        # App entry, named routes, Provider tree
├── config/
│   └── firebase_config.dart         # Firebase credentials + feature flags
├── models/
│   ├── user_model.dart              # UserModel + UserRole enum
│   ├── patient_record.dart          # PatientRecord + PatientStatus
│   ├── case_model.dart              # CaseModel for AI analysis cases
│   ├── stl_file_model.dart          # STL file metadata
│   ├── attachment_detection_model.dart
│   ├── effectiveness_score_model.dart
│   ├── predictability_model.dart
│   ├── recommendation_model.dart
│   └── validation_model.dart
├── providers/
│   ├── auth_provider.dart           # Auth state, doctor stream, SharedPrefs sync
│   ├── patient_provider.dart        # Patient list, file byte cache
│   ├── theme_provider.dart          # Light/dark mode
│   ├── mock_providers.dart          # Legacy mock providers
│   └── providers.dart              # Barrel export
├── services/
│   ├── firebase_auth_service.dart   # Email + Google sign-in/out
│   ├── firestore_service.dart       # Firestore CRUD + watchDoctors() stream
│   ├── firebase_storage_service.dart
│   └── database_service.dart        # SQLite (no-op on web)
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart            # Role tabs, email + Google login
│   ├── register_screen.dart         # Role selection on sign-up
│   ├── forgot_password_screen.dart
│   ├── dashboard_screen.dart        # Doctor's main portal
│   ├── researcher_screen.dart       # Researcher portal + PatientEntryScreen
│   │                                # + PatientDetailScreen + _DoctorAnalysisReport
│   │                                # + _SendReportSheet + PDF helpers
│   ├── stl_upload_screen.dart       # Doctor file upload with patient picker
│   ├── cases_list_screen.dart
│   ├── new_case_screen.dart
│   ├── case_detail_screen.dart
│   ├── settings_screen.dart
│   └── placeholder_screens.dart
├── widgets/
│   └── custom_widgets.dart          # Reusable UI components
├── theme/
│   └── app_theme.dart               # AppColors, AppGradients, text styles
└── utils/
    ├── constants.dart
    └── validators.dart
```

---

## Getting Started

### Prerequisites
- Flutter 3.x SDK (`flutter --version`)
- A Firebase project with **Authentication** and **Firestore** enabled
- Chrome browser (primary target — Flutter web)

### Installation

```bash
# 1. Clone the repo
git clone <your-repo-url>
cd ai_orthodontic

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome
flutter run -d chrome
```

### Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com) → Create a project
2. **Authentication** → Sign-in method → Enable **Email/Password** and **Google**
3. **Firestore** → Create database → Start in test mode (update rules before production)
4. Go to **Project Settings → Your Apps → Web App** → copy credentials into `lib/config/firebase_config.dart`

```dart
// lib/config/firebase_config.dart
static const String webApiKey      = 'YOUR_API_KEY';
static const String webAuthDomain  = 'YOUR_PROJECT.firebaseapp.com';
static const String webProjectId   = 'YOUR_PROJECT_ID';
static const String webGoogleClientId = 'YOUR_OAUTH_CLIENT_ID.apps.googleusercontent.com';

static const bool useFirebase        = true;
static const bool useFirestore       = true;
static const bool enableGoogleSignIn = true;
```

5. Add the Google client ID to `web/index.html`:
```html
<meta name="google-signin-client-id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
```

### Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow write: if request.auth != null && request.auth.uid == userId;
      allow read:  if request.auth != null;   // needed for doctor picker
    }
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Firestore Collections

```
users/          { uid, email, name, role, specialization, licenseNumber, createdAt }
cases/          { caseId, userId, patientName, status, stlFileIds, createdAt }
stl_files/      { fileId, caseId, fileName, fileUrl, uploadedAt }
analyses/       { analysisId, caseId, result, effectivenessScore, createdAt }
```

---

## Key Implementation Notes

| Topic | Detail |
|---|---|
| Google Sign-In on web | Uses `_auth.signInWithPopup(GoogleAuthProvider())` — avoids `origin_mismatch` |
| SQLite on web | All `DatabaseService` methods return early with `if (kIsWeb) return;` |
| Doctor list persistence | SharedPreferences + Firestore `watchDoctors()` stream; survives logout |
| File bytes on web | `FilePicker` returns `PlatformFile.bytes` (Uint8List); stored in `PatientProvider._fileCache` |
| PDF generation | `pdf` package builds multi-page A4 PDF client-side; downloaded via `dart:html` blob URL |
| WhatsApp delivery | `wa.me/{phone}` opens WhatsApp; PDF must be manually attached (browser security limitation) |
| Email delivery | `mailto:` link pre-fills recipient, subject, body; PDF is downloaded for manual attachment |

---

## Limitations (Current)

- **File storage is in-memory only** — uploaded files are lost on page refresh. Firebase Storage integration (`useFirebaseStorage = true`) is the path to persistent file storage.
- **WhatsApp cannot auto-attach PDFs** — this is a browser security restriction. The PDF is downloaded; the doctor attaches it manually in WhatsApp Web.
- **SQLite is disabled on web** — Firestore is the only persistent store on web.
- **AI analysis modules are not yet integrated** — the detection, scoring, and recommendation pipelines are modelled but not connected to a real ML backend.

---

## Version

**v1.0.0-beta** · Flutter 3.44 · Firebase project: `ai-orthodontic`  
Last updated: June 2026
