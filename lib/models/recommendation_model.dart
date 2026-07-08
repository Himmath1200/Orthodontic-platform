import 'package:equatable/equatable.dart';

class RecommendationModel extends Equatable {
  final String recommendationId;
  final String caseId;
  final String detectionId;
  final String effectivenessScoreId;
  final List<AttachmentRecommendation> recommendations;
  final DateTime generatedAt;
  final String overallGuidance;

  const RecommendationModel({
    required this.recommendationId,
    required this.caseId,
    required this.detectionId,
    required this.effectivenessScoreId,
    required this.recommendations,
    required this.generatedAt,
    required this.overallGuidance,
  });

  factory RecommendationModel.fromMap(Map<String, dynamic> map) {
    final recList = map['recommendations'] as List? ?? [];
    final recommendations = recList
        .map((item) => AttachmentRecommendation.fromMap(item))
        .toList();

    return RecommendationModel(
      recommendationId: map['recommendationId'] ?? '',
      caseId: map['caseId'] ?? '',
      detectionId: map['detectionId'] ?? '',
      effectivenessScoreId: map['effectivenessScoreId'] ?? '',
      recommendations: recommendations,
      generatedAt: map['generatedAt']?.toDate() ?? DateTime.now(),
      overallGuidance: map['overallGuidance'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recommendationId': recommendationId,
      'caseId': caseId,
      'detectionId': detectionId,
      'effectivenessScoreId': effectivenessScoreId,
      'recommendations': recommendations.map((r) => r.toMap()).toList(),
      'generatedAt': generatedAt,
      'overallGuidance': overallGuidance,
    };
  }

  @override
  List<Object?> get props => [
        recommendationId,
        caseId,
        detectionId,
        effectivenessScoreId,
        recommendations,
        generatedAt,
        overallGuidance,
      ];
}

class AttachmentRecommendation extends Equatable {
  final int toothNumber;
  final String currentPosition;
  final String suggestedPosition;
  final double positionOffsetMM;
  final String currentOrientation;
  final String suggestedOrientation;
  final String currentSize;
  final String suggestedSize;
  final String currentShape;
  final String suggestedShape;
  final String biomechanicalRationale;
  final double confidenceScore;
  final int priority;
  final String clinicalExplanation;

  const AttachmentRecommendation({
    required this.toothNumber,
    required this.currentPosition,
    required this.suggestedPosition,
    required this.positionOffsetMM,
    required this.currentOrientation,
    required this.suggestedOrientation,
    required this.currentSize,
    required this.suggestedSize,
    required this.currentShape,
    required this.suggestedShape,
    required this.biomechanicalRationale,
    required this.confidenceScore,
    required this.priority,
    required this.clinicalExplanation,
  });

  factory AttachmentRecommendation.fromMap(Map<String, dynamic> map) {
    return AttachmentRecommendation(
      toothNumber: map['toothNumber'] ?? 0,
      currentPosition: map['currentPosition'] ?? '',
      suggestedPosition: map['suggestedPosition'] ?? '',
      positionOffsetMM: (map['positionOffsetMM'] ?? 0).toDouble(),
      currentOrientation: map['currentOrientation'] ?? '',
      suggestedOrientation: map['suggestedOrientation'] ?? '',
      currentSize: map['currentSize'] ?? '',
      suggestedSize: map['suggestedSize'] ?? '',
      currentShape: map['currentShape'] ?? '',
      suggestedShape: map['suggestedShape'] ?? '',
      biomechanicalRationale: map['biomechanicalRationale'] ?? '',
      confidenceScore: (map['confidenceScore'] ?? 0).toDouble(),
      priority: map['priority'] ?? 0,
      clinicalExplanation: map['clinicalExplanation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toothNumber': toothNumber,
      'currentPosition': currentPosition,
      'suggestedPosition': suggestedPosition,
      'positionOffsetMM': positionOffsetMM,
      'currentOrientation': currentOrientation,
      'suggestedOrientation': suggestedOrientation,
      'currentSize': currentSize,
      'suggestedSize': suggestedSize,
      'currentShape': currentShape,
      'suggestedShape': suggestedShape,
      'biomechanicalRationale': biomechanicalRationale,
      'confidenceScore': confidenceScore,
      'priority': priority,
      'clinicalExplanation': clinicalExplanation,
    };
  }

  @override
  List<Object?> get props => [
        toothNumber,
        currentPosition,
        suggestedPosition,
        positionOffsetMM,
        currentOrientation,
        suggestedOrientation,
        currentSize,
        suggestedSize,
        currentShape,
        suggestedShape,
        biomechanicalRationale,
        confidenceScore,
        priority,
        clinicalExplanation,
      ];
}
