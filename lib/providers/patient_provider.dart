import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/patient_record.dart';
import '../models/user_model.dart';

class PatientProvider extends ChangeNotifier {
  final List<PatientRecord> _patients = _buildMockData();

  // ── File byte cache — stores uploaded file bytes keyed by patientId + name ──
  final Map<String, Map<String, Uint8List>> _fileCache = {};

  void storeFiles(String patientId, Map<String, Uint8List> files) {
    _fileCache[patientId] = {...?_fileCache[patientId], ...files};
  }

  Uint8List? getFile(String patientId, String fileName) {
    return _fileCache[patientId]?[fileName];
  }

  /// Adds a file to a patient's attached-files list AND stores its bytes.
  void addFileToPatient(String patientId, String fileName, Uint8List bytes) {
    _fileCache[patientId] = {...?_fileCache[patientId], fileName: bytes};
    final idx = _patients.indexWhere((p) => p.patientId == patientId);
    if (idx != -1 && !_patients[idx].attachedFiles.contains(fileName)) {
      _patients[idx] = _patients[idx].copyWith(
        attachedFiles: [..._patients[idx].attachedFiles, fileName],
        updatedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  // ── Doctor registry — populated from AuthProvider via ProxyProvider ────────
  List<Map<String, String>> _availableDoctors = [
    {'id': 'demo_doctor_001', 'name': 'Dr. Sarah Johnson', 'specialization': 'Orthodontist'},
    {'id': 'demo_doctor_002', 'name': 'Dr. Michael Chen', 'specialization': 'Pedodontist'},
    {'id': 'demo_doctor_003', 'name': 'Dr. Priya Sharma', 'specialization': 'General Dentist'},
  ];

  List<Map<String, String>> get availableDoctors =>
      List.unmodifiable(_availableDoctors);

  /// Called by ProxyProvider whenever AuthProvider changes (new doctor signs up).
  void syncDoctors(List<UserModel> doctors) {
    if (doctors.isEmpty) return;
    final updated = doctors
        .map((d) => {
              'id': d.uid,
              'name': d.name,
              'specialization': d.specialization ?? 'Orthodontist',
            })
        .toList();
    // Skip if nothing changed
    if (updated.length == _availableDoctors.length &&
        updated.every((d) => _availableDoctors.any((e) => e['id'] == d['id']))) {
      return;
    }
    _availableDoctors = updated;
    // Schedule after build to avoid setState-during-build errors
    SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  List<PatientRecord> get allPatients => List.unmodifiable(_patients);

  /// Doctors see patients assigned to them.
  /// In demo mode any account also sees patients assigned to demo_doctor_001.
  List<PatientRecord> patientsForDoctor(String doctorId) {
    return _patients
        .where((p) =>
            p.assignedDoctorId == doctorId ||
            (doctorId != 'demo_doctor_001' &&
                p.assignedDoctorId == 'demo_doctor_001'))
        .where((p) => p.status != PatientStatus.pending)
        .toList();
  }

  /// Researchers see patients they created.
  /// In demo mode any researcher also sees demo_researcher_001's patients.
  List<PatientRecord> patientsForResearcher(String researcherId) {
    return _patients
        .where((p) =>
            p.researcherId == researcherId ||
            (researcherId != 'demo_researcher_001' &&
                p.researcherId == 'demo_researcher_001'))
        .toList();
  }

  Future<void> addPatient(PatientRecord patient) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _patients.insert(0, patient);
    notifyListeners();
  }

  Future<void> updateStatus(String patientId, PatientStatus status) async {
    final idx = _patients.indexWhere((p) => p.patientId == patientId);
    if (idx != -1) {
      _patients[idx] =
          _patients[idx].copyWith(status: status, updatedAt: DateTime.now());
      notifyListeners();
    }
  }

  /// Update full patient details (e.g. after doctor adds notes/report).
  Future<void> updatePatient(PatientRecord updated) async {
    final idx = _patients.indexWhere((p) => p.patientId == updated.patientId);
    if (idx != -1) {
      _patients[idx] = updated.copyWith(updatedAt: DateTime.now());
      notifyListeners();
    }
  }

  static List<PatientRecord> _buildMockData() {
    final now = DateTime.now();
    return [
      PatientRecord(
        patientId: 'pat_001',
        name: 'Rahul Mehta',
        age: 24,
        gender: 'Male',
        contactNumber: '+91 98765 43210',
        email: 'rahul.mehta@email.com',
        chiefComplaint: 'Crowding in upper front teeth, difficulty chewing',
        medicalHistory: 'No significant medical history. Non-smoker.',
        currentMedications: 'None',
        allergies: 'None known',
        notes: 'Patient is motivated for treatment. Requests fastest option.',
        assignedDoctorId: 'demo_doctor_001',
        assignedDoctorName: 'Dr. Sarah Johnson',
        researcherId: 'demo_researcher_001',
        researcherName: 'Dr. Arjun Nair',
        status: PatientStatus.inProgress,
        attachedFiles: [
          'upper_arch_scan.stl',
          'lower_arch_scan.stl',
          'xray_panoramic.jpg',
        ],
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      PatientRecord(
        patientId: 'pat_002',
        name: 'Priya Sharma',
        age: 19,
        gender: 'Female',
        contactNumber: '+91 91234 56789',
        email: 'priya.sharma@email.com',
        chiefComplaint: 'Overbite correction, spacing between teeth',
        medicalHistory: 'Mild asthma — uses inhaler occasionally.',
        currentMedications: 'Salbutamol inhaler (as needed)',
        allergies: 'Penicillin',
        notes: 'Sensitive to metal brackets — consider aligner therapy.',
        assignedDoctorId: 'demo_doctor_001',
        assignedDoctorName: 'Dr. Sarah Johnson',
        researcherId: 'demo_researcher_001',
        researcherName: 'Dr. Arjun Nair',
        status: PatientStatus.assigned,
        attachedFiles: [
          'full_arch_scan.stl',
          'bite_registration.stl',
        ],
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      PatientRecord(
        patientId: 'pat_003',
        name: 'Karthik Suresh',
        age: 32,
        gender: 'Male',
        contactNumber: '+91 97890 12345',
        email: 'karthik.s@email.com',
        chiefComplaint: 'Post-extraction space closure, Class II malocclusion',
        medicalHistory: 'Type 2 Diabetes — well controlled with medication.',
        currentMedications: 'Metformin 500mg twice daily',
        allergies: 'Latex',
        notes:
            'Healing may be slower due to diabetes — plan conservative timeline.',
        assignedDoctorId: 'demo_doctor_001',
        assignedDoctorName: 'Dr. Sarah Johnson',
        researcherId: 'demo_researcher_001',
        researcherName: 'Dr. Arjun Nair',
        status: PatientStatus.assigned,
        attachedFiles: [
          'upper_arch_scan.stl',
          'xray_periapical_#14.jpg',
          'clinical_photos.zip',
        ],
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      PatientRecord(
        patientId: 'pat_004',
        name: 'Ananya Krishnan',
        age: 16,
        gender: 'Female',
        contactNumber: '+91 88901 23456',
        email: 'ananya.k@email.com',
        chiefComplaint: 'Severe crowding, impacted canine #13',
        medicalHistory: 'No significant history.',
        currentMedications: 'None',
        allergies: 'None known',
        notes:
            'Needs CBCT before treatment planning. Refer for 3D imaging first.',
        assignedDoctorId: '',
        assignedDoctorName: 'Unassigned',
        researcherId: 'demo_researcher_001',
        researcherName: 'Dr. Arjun Nair',
        status: PatientStatus.pending,
        attachedFiles: ['panoramic_xray.jpg'],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
