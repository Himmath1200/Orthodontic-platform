import 'package:equatable/equatable.dart';

class PredictabilityResultModel extends Equatable {
  final String resultId;
  final String caseId;
  final String detectionId;
  final Map<int, ToothPredictability> toothPredictabilities;
  final double averagePredictability;
  final double trackingLossProbability;
  final DateTime generatedAt;
  final String predictabilityMap;
  final List<HighRiskTooth> highRiskTeeth;

  const PredictabilityResultModel({
    required this.resultId,
    required this.caseId,
    required this.detectionId,
    required this.toothPredictabilities,
    required this.averagePredictability,
    required this.trackingLossProbability,
    required this.generatedAt,
    required this.predictabilityMap,
    required this.highRiskTeeth,
  });

  factory PredictabilityResultModel.fromMap(Map<String, dynamic> map) {
    final toothPredMap = map['toothPredictabilities'] as Map? ?? {};
    final predictions = <int, ToothPredictability>{};
    toothPredMap.forEach((key, value) {
      predictions[int.parse(key.toString())] =
          ToothPredictability.fromMap(value);
    });

    final highRiskList = map['highRiskTeeth'] as List? ?? [];
    final highRiskTeeth =
        highRiskList.map((item) => HighRiskTooth.fromMap(item)).toList();

    return PredictabilityResultModel(
      resultId: map['resultId'] ?? '',
      caseId: map['caseId'] ?? '',
      detectionId: map['detectionId'] ?? '',
      toothPredictabilities: predictions,
      averagePredictability: (map['averagePredictability'] ?? 0).toDouble(),
      trackingLossProbability:
          (map['trackingLossProbability'] ?? 0).toDouble(),
      generatedAt: map['generatedAt']?.toDate() ?? DateTime.now(),
      predictabilityMap: map['predictabilityMap'] ?? '',
      highRiskTeeth: highRiskTeeth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resultId': resultId,
      'caseId': caseId,
      'detectionId': detectionId,
      'toothPredictabilities': toothPredictabilities
          .map((key, value) => MapEntry(key.toString(), value.toMap())),
      'averagePredictability': averagePredictability,
      'trackingLossProbability': trackingLossProbability,
      'generatedAt': generatedAt,
      'predictabilityMap': predictabilityMap,
      'highRiskTeeth': highRiskTeeth.map((t) => t.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        resultId,
        caseId,
        detectionId,
        toothPredictabilities,
        averagePredictability,
        trackingLossProbability,
        generatedAt,
        predictabilityMap,
        highRiskTeeth,
      ];
}

class ToothPredictability extends Equatable {
  final int toothNumber;
  final double predictabilityScore;
  final PredictabilityLevel level;
  final Map<String, double> movementScores;
  final double trackingErrorProbability;

  const ToothPredictability({
    required this.toothNumber,
    required this.predictabilityScore,
    required this.level,
    required this.movementScores,
    required this.trackingErrorProbability,
  });

  factory ToothPredictability.fromMap(Map<String, dynamic> map) {
    return ToothPredictability(
      toothNumber: map['toothNumber'] ?? 0,
      predictabilityScore: (map['predictabilityScore'] ?? 0).toDouble(),
      level: _parsePredictabilityLevel(map['level']),
      movementScores: Map<String, double>.from(map['movementScores'] ?? {}),
      trackingErrorProbability:
          (map['trackingErrorProbability'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toothNumber': toothNumber,
      'predictabilityScore': predictabilityScore,
      'level': level.toString().split('.').last,
      'movementScores': movementScores,
      'trackingErrorProbability': trackingErrorProbability,
    };
  }

  @override
  List<Object?> get props => [
        toothNumber,
        predictabilityScore,
        level,
        movementScores,
        trackingErrorProbability,
      ];
}

enum PredictabilityLevel {
  highPredictability,
  moderate,
  risk,
  highRisk,
}

PredictabilityLevel _parsePredictabilityLevel(String? level) {
  switch (level) {
    case 'highPredictability':
      return PredictabilityLevel.highPredictability;
    case 'moderate':
      return PredictabilityLevel.moderate;
    case 'risk':
      return PredictabilityLevel.risk;
    case 'highRisk':
      return PredictabilityLevel.highRisk;
    default:
      return PredictabilityLevel.moderate;
  }
}

class HighRiskTooth extends Equatable {
  final int toothNumber;
  final String riskType;
  final String cause;
  final String suggestedCorrection;
  final double riskScore;

  const HighRiskTooth({
    required this.toothNumber,
    required this.riskType,
    required this.cause,
    required this.suggestedCorrection,
    required this.riskScore,
  });

  factory HighRiskTooth.fromMap(Map<String, dynamic> map) {
    return HighRiskTooth(
      toothNumber: map['toothNumber'] ?? 0,
      riskType: map['riskType'] ?? '',
      cause: map['cause'] ?? '',
      suggestedCorrection: map['suggestedCorrection'] ?? '',
      riskScore: (map['riskScore'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toothNumber': toothNumber,
      'riskType': riskType,
      'cause': cause,
      'suggestedCorrection': suggestedCorrection,
      'riskScore': riskScore,
    };
  }

  @override
  List<Object?> get props =>
      [toothNumber, riskType, cause, suggestedCorrection, riskScore];
}

class BiomechanicsAssessmentModel extends Equatable {
  final String assessmentId;
  final String detectionId;
  final String caseId;
  final Map<int, ToothBiomechanics> toothBiomechanics;
  final Map<String, dynamic> movementEffectiveness;
  final DateTime generatedAt;

  const BiomechanicsAssessmentModel({
    required this.assessmentId,
    required this.detectionId,
    required this.caseId,
    required this.toothBiomechanics,
    required this.movementEffectiveness,
    required this.generatedAt,
  });

  factory BiomechanicsAssessmentModel.fromMap(Map<String, dynamic> map) {
    final biomechMap = map['toothBiomechanics'] as Map? ?? {};
    final biomechanics = <int, ToothBiomechanics>{};
    biomechMap.forEach((key, value) {
      biomechanics[int.parse(key.toString())] =
          ToothBiomechanics.fromMap(value);
    });

    return BiomechanicsAssessmentModel(
      assessmentId: map['assessmentId'] ?? '',
      detectionId: map['detectionId'] ?? '',
      caseId: map['caseId'] ?? '',
      toothBiomechanics: biomechanics,
      movementEffectiveness: map['movementEffectiveness'] ?? {},
      generatedAt: map['generatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assessmentId': assessmentId,
      'detectionId': detectionId,
      'caseId': caseId,
      'toothBiomechanics': toothBiomechanics
          .map((key, value) => MapEntry(key.toString(), value.toMap())),
      'movementEffectiveness': movementEffectiveness,
      'generatedAt': generatedAt,
    };
  }

  @override
  List<Object?> get props => [
        assessmentId,
        detectionId,
        caseId,
        toothBiomechanics,
        movementEffectiveness,
        generatedAt,
      ];
}

class ToothBiomechanics extends Equatable {
  final int toothNumber;
  final double rotationEffectiveness;
  final double extrusionEffectiveness;
  final double intrusionEffectiveness;
  final double torqueEffectiveness;
  final double translationEffectiveness;
  final double rootMovementEffectiveness;
  final double attachmentEffectivenessRating;
  final String recommendedMovementType;

  const ToothBiomechanics({
    required this.toothNumber,
    required this.rotationEffectiveness,
    required this.extrusionEffectiveness,
    required this.intrusionEffectiveness,
    required this.torqueEffectiveness,
    required this.translationEffectiveness,
    required this.rootMovementEffectiveness,
    required this.attachmentEffectivenessRating,
    required this.recommendedMovementType,
  });

  factory ToothBiomechanics.fromMap(Map<String, dynamic> map) {
    return ToothBiomechanics(
      toothNumber: map['toothNumber'] ?? 0,
      rotationEffectiveness: (map['rotationEffectiveness'] ?? 0).toDouble(),
      extrusionEffectiveness: (map['extrusionEffectiveness'] ?? 0).toDouble(),
      intrusionEffectiveness: (map['intrusionEffectiveness'] ?? 0).toDouble(),
      torqueEffectiveness: (map['torqueEffectiveness'] ?? 0).toDouble(),
      translationEffectiveness:
          (map['translationEffectiveness'] ?? 0).toDouble(),
      rootMovementEffectiveness:
          (map['rootMovementEffectiveness'] ?? 0).toDouble(),
      attachmentEffectivenessRating:
          (map['attachmentEffectivenessRating'] ?? 0).toDouble(),
      recommendedMovementType: map['recommendedMovementType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toothNumber': toothNumber,
      'rotationEffectiveness': rotationEffectiveness,
      'extrusionEffectiveness': extrusionEffectiveness,
      'intrusionEffectiveness': intrusionEffectiveness,
      'torqueEffectiveness': torqueEffectiveness,
      'translationEffectiveness': translationEffectiveness,
      'rootMovementEffectiveness': rootMovementEffectiveness,
      'attachmentEffectivenessRating': attachmentEffectivenessRating,
      'recommendedMovementType': recommendedMovementType,
    };
  }

  @override
  List<Object?> get props => [
        toothNumber,
        rotationEffectiveness,
        extrusionEffectiveness,
        intrusionEffectiveness,
        torqueEffectiveness,
        translationEffectiveness,
        rootMovementEffectiveness,
        attachmentEffectivenessRating,
        recommendedMovementType,
      ];
}
