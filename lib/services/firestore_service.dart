import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../config/firebase_config.dart';

/// Firestore cloud sync layer — mirrors the SQLite schema in the cloud.
/// All writes also go to SQLite via [DatabaseService]; Firestore is the
/// source of truth when multiple devices are involved.
class FirestoreService {
  late final FirebaseFirestore _fs = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _fs.collection(FirebaseConfig.usersCollection);

  CollectionReference<Map<String, dynamic>> get _cases =>
      _fs.collection(FirebaseConfig.casesCollection);

  CollectionReference<Map<String, dynamic>> get _stlFiles =>
      _fs.collection(FirebaseConfig.stlFilesCollection);

  CollectionReference<Map<String, dynamic>> get _analyses =>
      _fs.collection(FirebaseConfig.analysesCollection);

  // ── USER OPERATIONS ────────────────────────────────────────────────────────

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.uid).update({
      'name': user.name,
      'role': user.role.name,
      'profileImageUrl': user.profileImageUrl,
      'specialization': user.specialization,
      'licenseNumber': user.licenseNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return _userFromFirestore(uid, doc.data()!);
  }

  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    final snap = await _users.where('role', isEqualTo: role).get();
    return snap.docs
        .map((d) => _userFromFirestore(d.id, d.data()))
        .toList();
  }

  /// Real-time stream of all doctor accounts.
  /// Fires whenever any doctor signs up, updates profile, or is deleted.
  Stream<List<UserModel>> watchDoctors() {
    return _users
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => _userFromFirestore(d.id, d.data()))
            .toList());
  }

  UserModel _userFromFirestore(String uid, Map<String, dynamic> data) =>
      UserModel(
        uid: uid,
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == data['role'],
          orElse: () => UserRole.doctor,
        ),
        profileImageUrl: data['profileImageUrl'],
        specialization: data['specialization'],
        licenseNumber: data['licenseNumber'],
        isEmailVerified: data['isEmailVerified'] ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  // ── CASE OPERATIONS ────────────────────────────────────────────────────────

  Future<void> createCase(CaseModel c) async {
    await _cases.doc(c.caseId).set({
      ...c.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCase(CaseModel c) async {
    await _cases.doc(c.caseId).update({
      'patientName': c.patientName,
      'caseTitle': c.caseTitle,
      'description': c.description,
      'status': c.status.toString().split('.').last,
      'stlFileIds': c.stlFileIds,
      'latestAnalysisId': c.latestAnalysisId,
      'totalAnalyses': c.totalAnalyses,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCase(String caseId) async {
    final batch = _fs.batch();
    batch.delete(_cases.doc(caseId));

    // Delete associated STL files
    final stlSnap =
        await _stlFiles.where('caseId', isEqualTo: caseId).get();
    for (final doc in stlSnap.docs) {
      batch.delete(doc.reference);
    }

    // Delete associated analyses
    final analysisSnap =
        await _analyses.where('caseId', isEqualTo: caseId).get();
    for (final doc in analysisSnap.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<List<CaseModel>> getCasesByUser(String userId) async {
    final snap = await _cases
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .get();
    return snap.docs
        .map((d) => CaseModel.fromMap(d.data()))
        .toList();
  }

  Stream<List<CaseModel>> watchCasesByUser(String userId) {
    return _cases
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => CaseModel.fromMap(d.data())).toList());
  }

  Future<CaseModel?> getCaseById(String caseId) async {
    final doc = await _cases.doc(caseId).get();
    if (!doc.exists || doc.data() == null) return null;
    return CaseModel.fromMap(doc.data()!);
  }

  // ── STL FILE OPERATIONS ────────────────────────────────────────────────────

  Future<void> createSTLFile(STLFileModel f) async {
    await _stlFiles.doc(f.fileId).set({
      ...f.toMap(),
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSTLFileAnalysis(
      String fileId, String analysisId) async {
    await _stlFiles.doc(fileId).update({
      'analyzed': true,
      'analysisId': analysisId,
    });
  }

  Future<List<STLFileModel>> getSTLFilesByCase(String caseId) async {
    final snap = await _stlFiles
        .where('caseId', isEqualTo: caseId)
        .orderBy('uploadedAt', descending: true)
        .get();
    return snap.docs
        .map((d) => STLFileModel.fromMap(d.data()))
        .toList();
  }

  Future<void> deleteSTLFile(String fileId) async {
    await _stlFiles.doc(fileId).delete();
  }

  // ── ANALYSIS OPERATIONS ────────────────────────────────────────────────────

  Future<void> saveAnalysis({
    required String analysisId,
    required String caseId,
    required String stlFileId,
    required String analysisType,
    required Map<String, dynamic> result,
    double? effectivenessScore,
    double? predictabilityScore,
  }) async {
    await _analyses.doc(analysisId).set({
      'analysisId': analysisId,
      'caseId': caseId,
      'stlFileId': stlFileId,
      'analysisType': analysisType,
      'result': result,
      'effectivenessScore': effectivenessScore,
      'predictabilityScore': predictabilityScore,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getAnalysesByCase(String caseId) async {
    final snap = await _analyses
        .where('caseId', isEqualTo: caseId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // ── DASHBOARD STATS ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats(String userId) async {
    final snap = await _cases.where('userId', isEqualTo: userId).get();
    final cases = snap.docs.map((d) => d.data()).toList();

    int active = 0, completed = 0, analyzed = 0;
    for (final c in cases) {
      if (c['status'] == 'active') active++;
      if (c['status'] == 'completed') completed++;
      if (c['latestAnalysisId'] != null) analyzed++;
    }

    return {
      'total': cases.length,
      'active': active,
      'completed': completed,
      'analyzed': analyzed,
    };
  }
}
