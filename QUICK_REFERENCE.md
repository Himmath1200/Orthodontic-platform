# Quick Reference Guide - AI Orthodontic Flutter App

## 🎯 Current Status
- **Completion**: 40% (8/20 core modules complete)
- **Lines of Code**: 3000+ lines
- **Screens**: 15 (8 functional, 7 placeholders)
- **Next Priority**: STL Upload Implementation

## 🚀 Quick Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build release
flutter build apk
flutter build ios

# Clean build
flutter clean && flutter pub get && flutter run

# Format code
dart format lib/

# Analyze code
dart analyze

# Run tests
flutter test
```

## 📍 Important File Locations

| Need | Location |
|------|----------|
| App entry point | `lib/main.dart` |
| Theme & colors | `lib/theme/app_theme.dart` |
| Custom widgets | `lib/widgets/custom_widgets.dart` |
| All models | `lib/models/*.dart` |
| Firebase services | `lib/firebase/*.dart` |
| State management | `lib/providers/*.dart` |
| All screens | `lib/screens/*.dart` |
| Dependencies | `pubspec.yaml` |

## 🔐 Demo Credentials

```
Email: demo@orthodontic.com
Password: Demo@12345
```

## 🎨 Color Palette

```dart
AppColors.primary       // #2E5090 (Blue)
AppColors.secondary     // #0DA77F (Teal)
AppColors.success       // #10B981 (Green)
AppColors.warning       // #F59E0B (Orange)
AppColors.error         // #EF4444 (Red)
AppColors.background    // #F9FAFB (Light gray)
AppColors.surface       // #FFFFFF (White)
```

## 📱 Screen Routes

```dart
/splash              // App startup
/login               // User login
/register            // Sign up
/forgot-password     // Password recovery
/dashboard           // Main dashboard
/cases               // Cases list
/new-case            // Create case
/case-detail         // Case details (args: caseId)
/settings            // User settings
/stl-upload          // STL file upload
/reports             // Reports
/attachment-detection // Analysis results
/predictability      // 3D visualization
/risk-analysis       // Risk heatmap
/recommendations     // AI recommendations
/validation          // Case validation
```

## 🔄 Common Code Patterns

### Navigate to Screen
```dart
Navigator.of(context).pushNamed('/cases');
Navigator.of(context).pushNamed('/case-detail', arguments: caseId);
```

### Read Provider Data
```dart
final auth = context.read<AuthProvider>();
final cases = context.read<CaseProvider>();
```

### Listen to Provider Changes
```dart
Consumer<CaseProvider>(
  builder: (context, provider, _) {
    return Text(provider.cases.length.toString());
  },
)
```

### Show Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Message')),
);
```

### Show Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Title'),
    content: Text('Content'),
  ),
);
```

### Form Validation
```dart
if (_formKey.currentState!.validate()) {
  // Form is valid
}
```

### Async Operation with Loading
```dart
Consumer<MyProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    return myContent;
  },
)
```

## 🔥 Firebase Operations Quick Tips

### Get User Cases
```dart
final caseProvider = context.read<CaseProvider>();
await caseProvider.fetchUserCases(userId);
```

### Create New Case
```dart
final caseProvider = context.read<CaseProvider>();
final caseId = await caseProvider.createCase(
  userId: userId,
  patientId: patientId,
  patientName: patientName,
  caseTitle: title,
  description: desc,
);
```

### Upload File
```dart
final fileProvider = context.read<STLFileProvider>();
await fileProvider.uploadSTLFile(
  caseId: caseId,
  file: file,
  onProgress: (progress) => print('$progress%'),
);
```

### Get Analysis Results
```dart
final analysisProvider = context.read<AnalysisProvider>();
final effectiveness = analysisProvider.effectivenessScores;
```

## 🛠️ Debug Tips

### Check Current Route
```dart
Navigator.of(context).currentRoute?.name
```

### Print Provider State
```dart
print(context.read<CaseProvider>().cases);
```

### View Logs
```bash
flutter logs
```

### Debug Mode Info
- Press 'w' in terminal during run: Hot reload
- Press 'r' in terminal during run: Hot restart
- Press 'd' in terminal during run: Detach

### Toggle Debug Paint
```bash
# Press 'p' during debug mode to visualize widget layers
```

## 📦 Key Dependencies

| Package | Version | Use |
|---------|---------|-----|
| flutter | latest | UI framework |
| firebase_core | 2.24.0+ | Firebase setup |
| firebase_auth | 4.15.0+ | Authentication |
| cloud_firestore | 4.14.0+ | Database |
| firebase_storage | 11.5.0+ | File storage |
| provider | 6.1.0 | State management |
| freezed_annotation | Latest | Model generation |
| file_picker | 5.0+ | File selection |
| pdf | 3.10+ | PDF generation |
| model_viewer_plus | 2.0+ | 3D visualization |
| fl_chart | 0.65+ | Charts & graphs |

## 🎯 Module Completion Checklist

### Module 1: Setup
- ✅ Project structure
- ✅ Firebase config
- ✅ Routing
- ✅ Theme system

### Module 2: STL Upload (NEXT)
- ⬜ File picker UI
- ⬜ Upload progress
- ⬜ File validation
- ⬜ Storage integration

### Modules 3-12
- ⬜ Attachment detection
- ⬜ Parameter extraction
- ⬜ Effectiveness scoring
- ⬜ Predictability viz
- ⬜ Risk analysis
- ⬜ Recommendations
- ⬜ Validation
- ⬜ Reports
- ⬜ Advanced features
- ⬜ Testing

## ⚡ Performance Tips

1. Use `const` for all constant widgets
2. Use `ListView.builder` for long lists
3. Implement `.copyWith()` for immutable updates
4. Cache images with `cacheWidth` and `cacheHeight`
5. Use `SingleChildScrollView` sparingly
6. Limit Firestore queries with `.limit(10)`
7. Use field projection in Firestore: `.select(['field1', 'field2'])`

## 🔍 Testing Demo Flow

1. App starts → Splash screen (2 seconds)
2. Login screen appears
3. Enter: demo@orthodontic.com / Demo@12345
4. Dashboard loads with statistics
5. Click "My Cases" → View/manage cases
6. Click "New Case" → Create case form
7. Click Settings → Profile & theme options
8. Click Logout → Back to login

## 📊 Data Structure Quick Reference

### User
```dart
{
  uid, name, email, role, photoUrl,
  createdAt, updatedAt
}
```

### Case
```dart
{
  caseId, userId, patientId, patientName,
  caseTitle, description, status, latestAnalysisId,
  createdAt, updatedAt
}
```

### STL File
```dart
{
  fileId, caseId, fileName, fileUrl, fileSize,
  uploadDate, processingStatus
}
```

### Analysis Result
```dart
{
  analysisId, caseId, detectionResults,
  effectivenessScore, riskFactors, timestamp
}
```

## 🐛 Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| Hot reload not working | Hot restart: Ctrl+Shift+F5 |
| Firebase not initializing | Check firebase_options.dart |
| Provider not updating | Call notifyListeners() |
| Route not found | Add route to main.dart |
| Widget not rebuilding | Wrap with Consumer |
| Build errors | `flutter clean && flutter pub get` |

## 📚 Documentation Files

- `README.md` - Project overview
- `DEVELOPMENT_GUIDE.md` - Implementation patterns
- `PROJECT_STATUS.md` - Progress tracking
- `QUICK_REFERENCE.md` - This file

## 🚀 Next Steps for New Developer

1. Read `README.md` (5 min)
2. Read `DEVELOPMENT_GUIDE.md` (10 min)
3. Run the app with demo credentials (5 min)
4. Check `PROJECT_STATUS.md` for what to implement (5 min)
5. Start with Module 2: STL Upload (2-3 hours)

## 📞 Quick Support

- **Flutter Docs**: https://flutter.dev/docs
- **Firebase**: https://firebase.flutter.dev/
- **Provider**: https://pub.dev/packages/provider
- **Material Design**: https://m3.material.io/

---

**Version**: 1.0.0  
**Last Updated**: Current Session  
**Status**: Foundation Complete, Ready for Implementation
