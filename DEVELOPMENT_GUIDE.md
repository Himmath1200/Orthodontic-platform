# AI Orthodontic - Development Guide

## Current Status Summary

**Overall Progress**: 40% Complete
- Foundation fully established
- 15 screens created (8 functional + 7 placeholders)
- All data models implemented
- Firebase services integrated
- State management configured
- Theme system complete
- Navigation routing configured

## Quick Reference - File Locations

| Component | File |
|-----------|------|
| App Entry | `lib/main.dart` |
| Models | `lib/models/*.dart` |
| Firebase Services | `lib/firebase/*.dart` |
| State Providers | `lib/providers/*.dart` |
| UI Screens | `lib/screens/*.dart` |
| Widgets | `lib/widgets/custom_widgets.dart` |
| Theme | `lib/theme/app_theme.dart` |
| Config | `pubspec.yaml` |

## Module Implementation Guide

### Module 1: Project Setup ✅ COMPLETE
**Status**: Fully implemented
- pubspec.yaml with all dependencies
- Folder structure
- Firebase initialization
- Theme system
- Basic routing

### Module 2: STL Upload (NEXT PRIORITY)
**Files to Create**:
1. `lib/services/ai_processing_service.dart` - Mock AI service
2. Update `lib/screens/stl_upload_screen.dart` - Full implementation

**Key Functions**:
```dart
// In STLFileProvider
Future<void> uploadSTLFile({
  required String caseId,
  required File file,
  required Function(double) onProgress,
})

// In StorageService
Future<String> uploadSTLFile({
  required String caseId,
  required File file,
  required Function(double) onProgress,
})
```

**Implementation Steps**:
1. Add file picker functionality
2. Implement upload progress UI
3. Add file validation (STL format check)
4. Store file metadata in Firestore
5. Create visual feedback

### Module 3: Attachment Detection
**Placeholder Screen**: `ReportsScreen` in `placeholder_screens.dart`

**Key Components**:
- AI model integration
- Attachment type classification
- Confidence scoring
- Tooth numbering system (1-32)

**Data Flow**:
```
User uploads STL → File processing → Detection → Store results → Display
```

### Module 4: Parameter Extraction
**Calculates**:
- Geometric properties (Height, Width, Depth)
- Surface area and volume
- Position coordinates (x, y, z)
- Orientation angles
- Resistance center distance

### Modules 5-12
See placeholder screens in `lib/screens/placeholder_screens.dart`

## How to Add a New Screen

### Step 1: Create Screen File
```dart
// lib/screens/my_new_screen.dart
import 'package:flutter/material.dart';

class MyNewScreen extends StatelessWidget {
  const MyNewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
      body: // your UI here
    );
  }
}
```

### Step 2: Add Route to main.dart
```dart
// In MaterialApp routes map:
'/my-route': (context) => const MyNewScreen(),
```

### Step 3: Navigate to Screen
```dart
Navigator.of(context).pushNamed('/my-route');
```

## How to Add State Management

### Step 1: Create Provider
```dart
// lib/providers/my_provider.dart
class MyProvider extends ChangeNotifier {
  List<MyData> _items = [];

  List<MyData> get items => _items;

  Future<void> loadItems() async {
    _items = await firestore.getItems();
    notifyListeners();
  }
}
```

### Step 2: Register in main.dart
```dart
ChangeNotifierProvider(create: (_) => MyProvider()),
```

### Step 3: Use in Screen
```dart
Consumer<MyProvider>(
  builder: (context, myProvider, _) {
    return ListView.builder(
      itemCount: myProvider.items.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(myProvider.items[index].name));
      },
    );
  },
)
```

## Common Patterns

### Form Validation
```dart
TextFormField(
  controller: controller,
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'This field is required';
    }
    return null;
  },
)
```

### Error Handling
```dart
try {
  await provider.someOperation();
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

### Loading States
```dart
Consumer<MyProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return const CircularProgressIndicator();
    }
    return myContent;
  },
)
```

## Firebase Operations

### Firestore - Create
```dart
await firestore.collection('cases').doc(caseId).set({
  'name': name,
  'createdAt': DateTime.now(),
});
```

### Firestore - Read
```dart
final doc = await firestore.collection('cases').doc(caseId).get();
final case = CaseModel.fromMap(doc.data() as Map<String, dynamic>);
```

### Firestore - Update
```dart
await firestore.collection('cases').doc(caseId).update({
  'status': 'completed',
  'updatedAt': DateTime.now(),
});
```

### Storage - Upload
```dart
final ref = storage.ref('cases/$caseId/stl_files/$fileName');
await ref.putFile(file);
final url = await ref.getDownloadURL();
```

## Testing Locally

### Demo Credentials (Pre-configured)
- **Email**: demo@orthodontic.com
- **Password**: Demo@12345

### Quick Test Flow
1. Start app → Splash screen
2. Login with demo credentials
3. View dashboard
4. Create new case
5. View cases list
6. Access settings

## Debugging Tips

### Check Provider State
```dart
// In any screen:
debugPrint(context.read<MyProvider>().items.toString());
```

### Monitor Firestore
Use Firebase Console → Firestore to view:
- Data structure
- Collection sizes
- Real-time updates

### View App Logs
```bash
flutter logs
```

### Hot Reload vs Hot Restart
- **Hot Reload** (Ctrl+S): Code changes only
- **Hot Restart** (Ctrl+Shift+F5): Full app restart

## Performance Optimization

### Image Caching
```dart
Image.network(
  url,
  cacheWidth: 500,
  cacheHeight: 500,
)
```

### Lazy Loading
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(...),
)
```

### Efficient Queries
```dart
// Good - only fetches needed fields
firestore
  .collection('cases')
  .where('userId', isEqualTo: uid)
  .limit(10)
  .get()
```

## Code Style Guidelines

- Use `const` for constant widgets
- Prefix private variables with `_`
- Use `late` for lazy initialization
- Keep methods focused and single-purpose
- Add comments for complex logic
- Use meaningful variable names

## Troubleshooting

### Issue: Hot reload not working
**Solution**: Hot restart or rebuild

### Issue: Firebase not initializing
**Solution**: Check firebase_options.dart credentials

### Issue: Provider not updating
**Solution**: Ensure notifyListeners() is called

### Issue: Build fails
**Solution**: 
```bash
flutter clean
flutter pub get
flutter run
```

## Next Implementation Tasks (In Priority Order)

1. ✅ **Complete**: All placeholder screens created
2. **Next**: Implement STL upload full functionality
3. **Then**: Create AI processing mock service
4. **Then**: Build attachment detection UI
5. **Then**: Implement 3D visualization
6. **Then**: Create recommendation engine
7. **Then**: Build reporting module
8. **Then**: Add testing suite

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)

---

**Last Updated**: Current Session  
**Version**: 1.0.0  
**For**: Development Team
