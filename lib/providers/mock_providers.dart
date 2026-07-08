import 'package:flutter/foundation.dart';
import '../models/models.dart';

// ============================================
// MOCK CASE PROVIDER
// ============================================

class MockCaseProvider extends ChangeNotifier {
  List<CaseModel> _cases = [];
  CaseModel? _selectedCase;
  bool _isLoading = false;

  List<CaseModel> get cases => _cases;
  CaseModel? get selectedCase => _selectedCase;
  bool get isLoading => _isLoading;

  Future<void> fetchUserCases() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _cases = [
      CaseModel(
        caseId: 'case_001',
        userId: 'user_001',
        patientId: 'patient_001',
        patientName: 'John Doe',
        caseTitle: 'Case 1',
        status: CaseStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CaseModel(
        caseId: 'case_002',
        userId: 'user_001',
        patientId: 'patient_002',
        patientName: 'Jane Smith',
        caseTitle: 'Case 2',
        status: CaseStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createCase(CaseModel newCase) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _cases.add(newCase);
    _isLoading = false;
    notifyListeners();
  }

  void selectCase(CaseModel selectedCaseModel) {
    _selectedCase = selectedCaseModel;
    notifyListeners();
  }

  Future<void> updateCase(CaseModel updatedCase) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 700));
    final index = _cases.indexWhere((c) => c.caseId == updatedCase.caseId);
    if (index != -1) {
      _cases[index] = updatedCase;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCase(String caseId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 700));
    _cases.removeWhere((c) => c.caseId == caseId);
    _isLoading = false;
    notifyListeners();
  }
}

// ============================================
// MOCK STL FILE PROVIDER
// ============================================

class MockSTLFileProvider extends ChangeNotifier {
  List<STLFileModel> _files = [];
  bool _isLoading = false;
  double _uploadProgress = 0;

  List<STLFileModel> get files => _files;
  bool get isLoading => _isLoading;
  double get uploadProgress => _uploadProgress;

  Future<void> fetchCaseSTLFiles(String caseId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadSTLFile({
    required String caseId,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    _isLoading = true;
    _uploadProgress = 0;
    notifyListeners();

    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _uploadProgress = i / 10;
      onProgress?.call(_uploadProgress);
      notifyListeners();
    }

    final newFile = STLFileModel(
      fileId: 'file_${DateTime.now().millisecondsSinceEpoch}',
      caseId: caseId,
      fileName: fileName,
      fileUrl: '/assets/stl/sample.stl',
      storagePath: 'cases/$caseId/scans/$fileName',
      uploadedAt: DateTime.now(),
      fileSizeBytes: 2500000,
      fileType: STLFileType.dentalModel,
    );

    _files.add(newFile);
    _isLoading = false;
    _uploadProgress = 0;
    notifyListeners();
  }

  Future<void> deleteSTLFile(String fileId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _files.removeWhere((f) => f.fileId == fileId);
    _isLoading = false;
    notifyListeners();
  }
}

// ============================================
// MOCK ANALYSIS PROVIDER
// ============================================

class MockAnalysisProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadAnalysisForCase(String caseId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }
}
