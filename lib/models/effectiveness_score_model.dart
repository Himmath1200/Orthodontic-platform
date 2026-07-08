import 'package:equatable/equatable.dart';

class EffectivenessScoreModel extends Equatable {
  final String scoreId;
  final String detectionId;
  final String caseId;
  final Map<int, ToothEffectivenessScore> toothScores;
  final double overallScore;
  final EffectivenessCategory category;
  final DateTime generatedAt;
  final List<String> recommendations;
  final Map<String, dynamic> scoringFactors;

  const EffectivenessScoreModel({
    required this.scoreId,
    required this.detectionId,
    required this.caseId,
    required this.toothScores,
    required this.overallScore,
    required this.category,
    required this.generatedAt,
    required this.recommendations,
    required this.scoringFactors,
  });

  factory EffectivenessScoreModel.fromMap(Map<String, dynamic> map) {
    final toothScoresMap = map['toothScores'] as Map? ?? {};
    final scores = <int, ToothEffectivenessScore>{};
    toothScoresMap.forEach((key, value) {
      scores[int.parse(key.toString())] =
          ToothEffectivenessScore.fromMap(value);
    });

    return EffectivenessScoreModel(
      scoreId: map['scoreId'] ?? '',
      detectionId: map['detectionId'] ?? '',
      caseId: map['caseId'] ?? '',
      toothScores: scores,
      overallScore: (map['overallScore'] ?? 0).toDouble(),
      category: _parseEffectivenessCategory(map['category']),
      generatedAt: map['generatedAt']?.toDate() ?? DateTime.now(),
      recommendations:
          List<String>.from(map['recommendations'] ?? []),
      scoringFactors: map['scoringFactors'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scoreId': scoreId,
      'detectionId': detectionId,
      'caseId': caseId,
      'toothScores': toothScores
          .map((key, value) => MapEntry(key.toString(), value.toMap())),
      'overallScore': overallScore,
      'category': category.toString().split('.').last,
      'generatedAt': generatedAt,
      'recommendations': recommendations,
      'scoringFactors': scoringFactors,
    };
  }

  @override
  List<Object?> get props => [
        scoreId,
        detectionId,
        caseId,
        toothScores,
        overallScore,
        category,
        generatedAt,
        recommendations,
        scoringFactors,
      ];
}

enum EffectivenessCategory {
  excellent,
  good,
  moderate,
  highRisk,
  poor,
}

EffectivenessCategory _parseEffectivenessCategory(String? category) {
  switch (category) {
    case 'excellent':
      return EffectivenessCategory.excellent;
    case 'good':
      return EffectivenessCategory.good;
    case 'moderate':
      return EffectivenessCategory.moderate;
    case 'highRisk':
      return EffectivenessCategory.highRisk;
    case 'poor':
      return EffectivenessCategory.poor;
    default:
      return EffectivenessCategory.moderate;
  }
}

class ToothEffectivenessScore extends Equatable {
  final int toothNumber;
  final double geometryScore;
  final double placementScore;
  final double orientationScore;
  final double biomechanicalScore;
  final double predictabilityScore;
  final double overallScore;
  final EffectivenessCategory category;
  final List<RiskFactor> riskFactors;

  const ToothEffectivenessScore({
    required this.toothNumber,
    required this.geometryScore,
    required this.placementScore,
    required this.orientationScore,
    required this.biomechanicalScore,
    required this.predictabilityScore,
    required this.overallScore,
    required this.category,
    required this.riskFactors,
  });

  factory ToothEffectivenessScore.fromMap(Map<String, dynamic> map) {
    final riskFactorsList = map['riskFactors'] as List? ?? [];
    final riskFactors = riskFactorsList
        .map((item) => RiskFactor.fromMap(item))
        .toList();

    return ToothEffectivenessScore(
      toothNumber: map['toothNumber'] ?? 0,
      geometryScore: (map['geometryScore'] ?? 0).toDouble(),
      placementScore: (map['placementScore'] ?? 0).toDouble(),
      orientationScore: (map['orientationScore'] ?? 0).toDouble(),
      biomechanicalScore: (map['biomechanicalScore'] ?? 0).toDouble(),
      predictabilityScore: (map['predictabilityScore'] ?? 0).toDouble(),
      overallScore: (map['overallScore'] ?? 0).toDouble(),
      category: _parseEffectivenessCategory(map['category']),
      riskFactors: riskFactors,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toothNumber': toothNumber,
      'geometryScore': geometryScore,
      'placementScore': placementScore,
      'orientationScore': orientationScore,
      'biomechanicalScore': biomechanicalScore,
      'predictabilityScore': predictabilityScore,
      'overallScore': overallScore,
      'category': category.toString().split('.').last,
      'riskFactors': riskFactors.map((r) => r.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        toothNumber,
        geometryScore,
        placementScore,
        orientationScore,
        biomechanicalScore,
        predictabilityScore,
        overallScore,
        category,
        riskFactors,
      ];
}

class RiskFactor extends Equatable {
  final String factor;
  final String severity;
  final String description;

  const RiskFactor({
    required this.factor,
    required this.severity,
    required this.description,
  });

  factory RiskFactor.fromMap(Map<String, dynamic> map) {
    return RiskFactor(
      factor: map['factor'] ?? '',
      severity: map['severity'] ?? 'low',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'factor': factor,
      'severity': severity,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [factor, severity, description];
}
