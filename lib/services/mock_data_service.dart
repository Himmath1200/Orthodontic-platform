// Simple mock data service - just returns demo data
import '../models/user_model.dart';
import '../models/case_model.dart';
import '../models/stl_file_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();

  factory MockDataService() {
    return _instance;
  }

  MockDataService._internal();

  // Simple demo data
  static const String demoCaseId = 'case_001';
  static const String demoUserId = 'user_001';
  
  String get currentCaseId => demoCaseId;
  String get currentUserId => demoUserId;
  
  // Get demo user
  UserModel getDemoUser() {
    return UserModel(
      uid: demoUserId,
      name: 'Dr. Sarah Johnson',
      email: 'demo@orthodontic.com',
      role: UserRole.doctor,
      profileImageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Get demo cases
  List<CaseModel> getCases() {
    return [
      CaseModel(
        caseId: 'case_001',
        userId: demoUserId,
        patientId: 'patient_001',
        patientName: 'John Doe',
        caseTitle: 'Case 1',
        status: CaseStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CaseModel(
        caseId: 'case_002',
        userId: demoUserId,
        patientId: 'patient_002',
        patientName: 'Jane Smith',
        caseTitle: 'Case 2',
        status: CaseStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CaseModel(
        caseId: 'case_003',
        userId: demoUserId,
        patientId: 'patient_003',
        patientName: 'Mike Johnson',
        caseTitle: 'Case 3',
        status: CaseStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  // Get STL files for a case
  List<STLFileModel> getSTLFilesForCase(String caseId) {
    return [
      STLFileModel(
        fileId: 'file_001',
        caseId: caseId,
        fileName: 'upper_arch.stl',
        fileUrl: '/assets/stl/upper.stl',
        storagePath: 'cases/$caseId/upper_arch.stl',
        uploadedAt: DateTime.now(),
        fileSizeBytes: 2500000,
        fileType: STLFileType.dentalModel,
      ),
      STLFileModel(
        fileId: 'file_002',
        caseId: caseId,
        fileName: 'lower_arch.stl',
        fileUrl: '/assets/stl/lower.stl',
        storagePath: 'cases/$caseId/lower_arch.stl',
        uploadedAt: DateTime.now(),
        fileSizeBytes: 2300000,
        fileType: STLFileType.dentalModel,
      ),
    ];
  }
  
  // Get simple demo data
  Map<String, dynamic> getDemoData() {
    return {
      'caseId': demoCaseId,
      'userId': demoUserId,
      'patientName': 'John Doe',
      'treatedTeeth': 24,
      'detectionConfidence': 92.5,
      'effectiveness': 87,
      'predictability': 82,
      'trackingLoss': 18,
      'overallAccuracy': 95,
    };
  }
  
  // Returns simple demo list
  List<Map<String, dynamic>> getAttachments() {
    return List.generate(24, (i) => {
      'tooth': i + 1,
      'type': i % 2 == 0 ? 'Button' : 'Hook',
      'confidence': 90 + (i % 5),
    });
  }
}
