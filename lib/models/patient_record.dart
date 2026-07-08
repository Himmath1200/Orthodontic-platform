enum PatientStatus { pending, assigned, inProgress, completed }

class PatientRecord {
  final String patientId;
  final String name;
  final int age;
  final String gender;
  final String contactNumber;
  final String email;
  final String chiefComplaint;
  final String medicalHistory;
  final String? currentMedications;
  final String? allergies;
  final String? notes;
  final String assignedDoctorId;
  final String assignedDoctorName;
  final String researcherId;
  final String researcherName;
  final PatientStatus status;
  final List<String> attachedFiles;
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientRecord({
    required this.patientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.contactNumber,
    required this.email,
    required this.chiefComplaint,
    required this.medicalHistory,
    this.currentMedications,
    this.allergies,
    this.notes,
    required this.assignedDoctorId,
    required this.assignedDoctorName,
    required this.researcherId,
    required this.researcherName,
    required this.status,
    this.attachedFiles = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  PatientRecord copyWith({
    String? patientId,
    String? name,
    int? age,
    String? gender,
    String? contactNumber,
    String? email,
    String? chiefComplaint,
    String? medicalHistory,
    String? currentMedications,
    String? allergies,
    String? notes,
    String? assignedDoctorId,
    String? assignedDoctorName,
    String? researcherId,
    String? researcherName,
    PatientStatus? status,
    List<String>? attachedFiles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientRecord(
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      currentMedications: currentMedications ?? this.currentMedications,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
      assignedDoctorName: assignedDoctorName ?? this.assignedDoctorName,
      researcherId: researcherId ?? this.researcherId,
      researcherName: researcherName ?? this.researcherName,
      status: status ?? this.status,
      attachedFiles: attachedFiles ?? this.attachedFiles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'name': name,
        'age': age,
        'gender': gender,
        'contactNumber': contactNumber,
        'email': email,
        'chiefComplaint': chiefComplaint,
        'medicalHistory': medicalHistory,
        'currentMedications': currentMedications,
        'allergies': allergies,
        'notes': notes,
        'assignedDoctorId': assignedDoctorId,
        'assignedDoctorName': assignedDoctorName,
        'researcherId': researcherId,
        'researcherName': researcherName,
        'status': status.name,
        'attachedFiles': attachedFiles,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
