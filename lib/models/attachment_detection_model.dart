import 'package:equatable/equatable.dart';

class AttachmentDetectionModel extends Equatable {
  final String detectionId;
  final String caseId;
  final String stlFileId;
  final List<Attachment> attachments;
  final DateTime analyzedAt;
  final double processingTimeSeconds;
  final String modelVersion;
  final double overallConfidence;

  const AttachmentDetectionModel({
    required this.detectionId,
    required this.caseId,
    required this.stlFileId,
    required this.attachments,
    required this.analyzedAt,
    required this.processingTimeSeconds,
    required this.modelVersion,
    required this.overallConfidence,
  });

  factory AttachmentDetectionModel.fromMap(Map<String, dynamic> map) {
    final attachmentsList = map['attachments'] as List?;
    final attachments = attachmentsList
            ?.map((item) => Attachment.fromMap(item))
            .toList() ??
        [];

    return AttachmentDetectionModel(
      detectionId: map['detectionId'] ?? '',
      caseId: map['caseId'] ?? '',
      stlFileId: map['stlFileId'] ?? '',
      attachments: attachments,
      analyzedAt: map['analyzedAt']?.toDate() ?? DateTime.now(),
      processingTimeSeconds: (map['processingTimeSeconds'] ?? 0).toDouble(),
      modelVersion: map['modelVersion'] ?? '',
      overallConfidence: (map['overallConfidence'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'detectionId': detectionId,
      'caseId': caseId,
      'stlFileId': stlFileId,
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'analyzedAt': analyzedAt,
      'processingTimeSeconds': processingTimeSeconds,
      'modelVersion': modelVersion,
      'overallConfidence': overallConfidence,
    };
  }

  @override
  List<Object?> get props => [
        detectionId,
        caseId,
        stlFileId,
        attachments,
        analyzedAt,
        processingTimeSeconds,
        modelVersion,
        overallConfidence,
      ];
}

class Attachment extends Equatable {
  final int attachmentId;
  final int toothNumber;
  final AttachmentType type;
  final double confidenceScore;
  final AttachmentGeometry geometry;
  final Position3D position;
  final Orientation orientation;
  final String boundingBoxUrl;
  final String segmentationUrl;

  const Attachment({
    required this.attachmentId,
    required this.toothNumber,
    required this.type,
    required this.confidenceScore,
    required this.geometry,
    required this.position,
    required this.orientation,
    this.boundingBoxUrl = '',
    this.segmentationUrl = '',
  });

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      attachmentId: map['attachmentId'] ?? 0,
      toothNumber: map['toothNumber'] ?? 0,
      type: _parseAttachmentType(map['type']),
      confidenceScore: (map['confidenceScore'] ?? 0).toDouble(),
      geometry: AttachmentGeometry.fromMap(map['geometry'] ?? {}),
      position: Position3D.fromMap(map['position'] ?? {}),
      orientation: Orientation.fromMap(map['orientation'] ?? {}),
      boundingBoxUrl: map['boundingBoxUrl'] ?? '',
      segmentationUrl: map['segmentationUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attachmentId': attachmentId,
      'toothNumber': toothNumber,
      'type': type.toString().split('.').last,
      'confidenceScore': confidenceScore,
      'geometry': geometry.toMap(),
      'position': position.toMap(),
      'orientation': orientation.toMap(),
      'boundingBoxUrl': boundingBoxUrl,
      'segmentationUrl': segmentationUrl,
    };
  }

  @override
  List<Object?> get props => [
        attachmentId,
        toothNumber,
        type,
        confidenceScore,
        geometry,
        position,
        orientation,
        boundingBoxUrl,
        segmentationUrl,
      ];
}

enum AttachmentType {
  rectangular,
  ellipsoid,
  optimized,
  rotation,
  extrusion,
  unknown,
}

AttachmentType _parseAttachmentType(String? type) {
  switch (type) {
    case 'rectangular':
      return AttachmentType.rectangular;
    case 'ellipsoid':
      return AttachmentType.ellipsoid;
    case 'optimized':
      return AttachmentType.optimized;
    case 'rotation':
      return AttachmentType.rotation;
    case 'extrusion':
      return AttachmentType.extrusion;
    default:
      return AttachmentType.unknown;
  }
}

class AttachmentGeometry extends Equatable {
  final double height;
  final double width;
  final double depth;
  final double surfaceArea;
  final double volume;
  final double boundingBoxVolume;

  const AttachmentGeometry({
    required this.height,
    required this.width,
    required this.depth,
    required this.surfaceArea,
    required this.volume,
    required this.boundingBoxVolume,
  });

  factory AttachmentGeometry.fromMap(Map<String, dynamic> map) {
    return AttachmentGeometry(
      height: (map['height'] ?? 0).toDouble(),
      width: (map['width'] ?? 0).toDouble(),
      depth: (map['depth'] ?? 0).toDouble(),
      surfaceArea: (map['surfaceArea'] ?? 0).toDouble(),
      volume: (map['volume'] ?? 0).toDouble(),
      boundingBoxVolume: (map['boundingBoxVolume'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'width': width,
      'depth': depth,
      'surfaceArea': surfaceArea,
      'volume': volume,
      'boundingBoxVolume': boundingBoxVolume,
    };
  }

  @override
  List<Object?> get props =>
      [height, width, depth, surfaceArea, volume, boundingBoxVolume];
}

class Position3D extends Equatable {
  final double x;
  final double y;
  final double z;
  final double distanceFromResistanceCenter;
  final String positionDescription;

  const Position3D({
    required this.x,
    required this.y,
    required this.z,
    required this.distanceFromResistanceCenter,
    this.positionDescription = '',
  });

  factory Position3D.fromMap(Map<String, dynamic> map) {
    return Position3D(
      x: (map['x'] ?? 0).toDouble(),
      y: (map['y'] ?? 0).toDouble(),
      z: (map['z'] ?? 0).toDouble(),
      distanceFromResistanceCenter:
          (map['distanceFromResistanceCenter'] ?? 0).toDouble(),
      positionDescription: map['positionDescription'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'distanceFromResistanceCenter': distanceFromResistanceCenter,
      'positionDescription': positionDescription,
    };
  }

  @override
  List<Object?> get props => [x, y, z, distanceFromResistanceCenter];
}

class Orientation extends Equatable {
  final double pitchAngle;
  final double rollAngle;
  final double yawAngle;
  final double meshAlignmentScore;

  const Orientation({
    required this.pitchAngle,
    required this.rollAngle,
    required this.yawAngle,
    required this.meshAlignmentScore,
  });

  factory Orientation.fromMap(Map<String, dynamic> map) {
    return Orientation(
      pitchAngle: (map['pitchAngle'] ?? 0).toDouble(),
      rollAngle: (map['rollAngle'] ?? 0).toDouble(),
      yawAngle: (map['yawAngle'] ?? 0).toDouble(),
      meshAlignmentScore: (map['meshAlignmentScore'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pitchAngle': pitchAngle,
      'rollAngle': rollAngle,
      'yawAngle': yawAngle,
      'meshAlignmentScore': meshAlignmentScore,
    };
  }

  @override
  List<Object?> get props => [pitchAngle, rollAngle, yawAngle, meshAlignmentScore];
}
