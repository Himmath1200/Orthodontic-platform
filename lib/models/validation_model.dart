import 'package:equatable/equatable.dart';

class ValidationReportModel extends Equatable {
  final String reportId;
  final String caseId;
  final String predictabilityResultId;
  final DateTime generatedAt;
  final DateTime? plannedCompletionDate;
  final DateTime? actualCompletionDate;
  final Map<int, ToothMovementValidation> toothMovements;
  final double averageTrackingSuccess;
  final double averagePredictionAccuracy;
  final double correlationCoefficient;
  final ValidationStatus status;
  final String notes;

  const ValidationReportModel({
    required this.reportId,
    required this.caseId,
    required this.predictabilityResultId,
    required this.generatedAt,
    this.plannedCompletionDate,
    this.actualCompletionDate,
    required this.toothMovements,
    required this.averageTrackingSuccess,
    required this.averagePredictionAccuracy,
    required this.correlationCoefficient,
    required this.status,
    required this.notes,
  });

  factory ValidationReportModel.fromMap(Map<String, dynamic> map) {
    final movementMap = map['toothMovements'] as Map? ?? {};
    final movements = <int, ToothMovementValidation>{};
    movementMap.forEach((key, value) {
      movements[int.parse(key.toString())] =
          ToothMovementValidation.fromMap(value);
    });

    return ValidationReportModel(
      reportId: map['reportId'] ?? '',
      caseId: map['caseId'] ?? '',
      predictabilityResultId: map['predictabilityResultId'] ?? '',
      generatedAt: map['generatedAt']?.toDate() ?? DateTime.now(),
      plannedCompletionDate: map['plannedCompletionDate']?.toDate(),
      actualCompletionDate: map['actualCompletionDate']?.toDate(),
      toothMovements: movements,
      averageTrackingSuccess:
          (map['averageTrackingSuccess'] ?? 0).toDouble(),
      averagePredictionAccuracy:
          (map['averagePredictionAccuracy'] ?? 0).toDouble(),
      correlationCoefficient:
          (map['correlationCoefficient'] ?? 0).toDouble(),
      status: _parseValidationStatus(map['status']),
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'caseId': caseId,
      'predictabilityResultId': predictabilityResultId,
      'generatedAt': generatedAt,
      'plannedCompletionDate': plannedCompletionDate,
      'actualCompletionDate': actualCompletionDate,
      'toothMovements': toothMovements
          .map((key, value) => MapEntry(key.toString(), value.toMap())),
      'averageTrackingSuccess': averageTrackingSuccess,
      'averagePredictionAccuracy': averagePredictionAccuracy,
      'correlationCoefficient': correlationCoefficient,
      'status': status.toString().split('.').last,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
        reportId,
        caseId,
        predictabilityResultId,
        generatedAt,
        plannedCompletionDate,
        actualCompletionDate,
        toothMovements,
        averageTrackingSuccess,
        averagePredictionAccuracy,
        correlationCoefficient,
        status,
        notes,
      ];
}

enum ValidationStatus {
  planning,
  inProgress,
  completed,
  review,
}

ValidationStatus _parseValidationStatus(String? status) {
  switch (status) {
    case 'planning':
      return ValidationStatus.planning;
    case 'inProgress':
      return ValidationStatus.inProgress;
    case 'completed':
      return ValidationStatus.completed;
    case 'review':
      return ValidationStatus.review;
    default:
      return ValidationStatus.planning;
  }
}

class ToothMovementValidation extends Equatable {
  final int toothNumber;
  final double plannedMovement;
  final double achievedMovement;
  final double trackingErrorMM;
  final double trackingSuccess;
  final double predictionAccuracy;
  final String movementType;
  final bool trackingFailed;

  const ToothMovementValidation({
    required this.toothNumber,
    required this.plannedMovement,
    required this.achievedMovement,
    required this.trackingErrorMM,
    required this.trackingSuccess,
    required this.predictionAccuracy,
    required this.movementType,
    required this.trackingFailed,
  });

  factory ToothMovementValidation.fromMap(Map<String, dynamic> map) {
    return ToothMovementValidation(
      toothNumber: map['toothNumber'] ?? 0,
      plannedMovement: (map['plannedMovement'] ?? 0).toDouble(),
      achievedMovement: (map['achievedMovement'] ?? 0).toDouble(),
      trackingErrorMM: (map['trackingErrorMM'] ?? 0).toDouble(),
      trackingSuccess: (map['trackingSuccess'] ?? 0).toDouble(),
      predictionAccuracy: (map['predictionAccuracy'] ?? 0).toDouble(),
      movementType: map['movementType'] ?? '',
      trackingFailed: map['trackingFailed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toothNumber': toothNumber,
      'plannedMovement': plannedMovement,
      'achievedMovement': achievedMovement,
      'trackingErrorMM': trackingErrorMM,
      'trackingSuccess': trackingSuccess,
      'predictionAccuracy': predictionAccuracy,
      'movementType': movementType,
      'trackingFailed': trackingFailed,
    };
  }

  @override
  List<Object?> get props => [
        toothNumber,
        plannedMovement,
        achievedMovement,
        trackingErrorMM,
        trackingSuccess,
        predictionAccuracy,
        movementType,
        trackingFailed,
      ];
}

class ClinicalReportModel extends Equatable {
  final String reportId;
  final String caseId;
  final String patientName;
  final String patientId;
  final DateTime generatedAt;
  final String clinicianName;
  final String clinicianEmail;
  final String clinicName;
  final Map<String, dynamic> summaryData;
  final List<String> attachmentUrls;
  final ReportStatus status;

  const ClinicalReportModel({
    required this.reportId,
    required this.caseId,
    required this.patientName,
    required this.patientId,
    required this.generatedAt,
    required this.clinicianName,
    required this.clinicianEmail,
    required this.clinicName,
    required this.summaryData,
    required this.attachmentUrls,
    required this.status,
  });

  factory ClinicalReportModel.fromMap(Map<String, dynamic> map) {
    return ClinicalReportModel(
      reportId: map['reportId'] ?? '',
      caseId: map['caseId'] ?? '',
      patientName: map['patientName'] ?? '',
      patientId: map['patientId'] ?? '',
      generatedAt: map['generatedAt']?.toDate() ?? DateTime.now(),
      clinicianName: map['clinicianName'] ?? '',
      clinicianEmail: map['clinicianEmail'] ?? '',
      clinicName: map['clinicName'] ?? '',
      summaryData: map['summaryData'] ?? {},
      attachmentUrls: List<String>.from(map['attachmentUrls'] ?? []),
      status: _parseReportStatus(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'caseId': caseId,
      'patientName': patientName,
      'patientId': patientId,
      'generatedAt': generatedAt,
      'clinicianName': clinicianName,
      'clinicianEmail': clinicianEmail,
      'clinicName': clinicName,
      'summaryData': summaryData,
      'attachmentUrls': attachmentUrls,
      'status': status.toString().split('.').last,
    };
  }

  @override
  List<Object?> get props => [
        reportId,
        caseId,
        patientName,
        patientId,
        generatedAt,
        clinicianName,
        clinicianEmail,
        clinicName,
        summaryData,
        attachmentUrls,
        status,
      ];
}

enum ReportStatus {
  draft,
  pending,
  generated,
  exported,
}

ReportStatus _parseReportStatus(String? status) {
  switch (status) {
    case 'draft':
      return ReportStatus.draft;
    case 'pending':
      return ReportStatus.pending;
    case 'generated':
      return ReportStatus.generated;
    case 'exported':
      return ReportStatus.exported;
    default:
      return ReportStatus.draft;
  }
}
