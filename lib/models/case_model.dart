import 'package:equatable/equatable.dart';

class CaseModel extends Equatable {
  final String caseId;
  final String userId;
  final String patientId;
  final String patientName;
  final String caseTitle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CaseStatus status;
  final String? description;
  final List<String> stlFileIds;
  final String? latestAnalysisId;
  final int totalAnalyses;

  const CaseModel({
    required this.caseId,
    required this.userId,
    required this.patientId,
    required this.patientName,
    required this.caseTitle,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.description,
    this.stlFileIds = const [],
    this.latestAnalysisId,
    this.totalAnalyses = 0,
  });

  factory CaseModel.fromMap(Map<String, dynamic> map) {
    return CaseModel(
      caseId: map['caseId'] ?? '',
      userId: map['userId'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      caseTitle: map['caseTitle'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      status: _parseCaseStatus(map['status']),
      description: map['description'],
      stlFileIds: List<String>.from(map['stlFileIds'] ?? []),
      latestAnalysisId: map['latestAnalysisId'],
      totalAnalyses: map['totalAnalyses'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'caseId': caseId,
      'userId': userId,
      'patientId': patientId,
      'patientName': patientName,
      'caseTitle': caseTitle,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status.toString().split('.').last,
      'description': description,
      'stlFileIds': stlFileIds,
      'latestAnalysisId': latestAnalysisId,
      'totalAnalyses': totalAnalyses,
    };
  }

  @override
  List<Object?> get props => [
        caseId,
        userId,
        patientId,
        patientName,
        caseTitle,
        createdAt,
        updatedAt,
        status,
        description,
        stlFileIds,
        latestAnalysisId,
        totalAnalyses,
      ];
}

enum CaseStatus {
  active,
  completed,
  archived,
  inReview,
}

CaseStatus _parseCaseStatus(String? status) {
  switch (status) {
    case 'active':
      return CaseStatus.active;
    case 'completed':
      return CaseStatus.completed;
    case 'archived':
      return CaseStatus.archived;
    case 'inReview':
      return CaseStatus.inReview;
    default:
      return CaseStatus.active;
  }
}
