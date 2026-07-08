import 'package:equatable/equatable.dart';

class STLFileModel extends Equatable {
  final String fileId;
  final String caseId;
  final String fileName;
  final String fileUrl;
  final String storagePath;
  final DateTime uploadedAt;
  final double fileSizeBytes;
  final STLFileType fileType;
  final String? description;
  final bool analyzed;
  final String? analysisId;

  const STLFileModel({
    required this.fileId,
    required this.caseId,
    required this.fileName,
    required this.fileUrl,
    required this.storagePath,
    required this.uploadedAt,
    required this.fileSizeBytes,
    required this.fileType,
    this.description,
    this.analyzed = false,
    this.analysisId,
  });

  factory STLFileModel.fromMap(Map<String, dynamic> map) {
    return STLFileModel(
      fileId: map['fileId'] ?? '',
      caseId: map['caseId'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      storagePath: map['storagePath'] ?? '',
      uploadedAt: map['uploadedAt']?.toDate() ?? DateTime.now(),
      fileSizeBytes: (map['fileSizeBytes'] ?? 0).toDouble(),
      fileType: _parseSTLFileType(map['fileType']),
      description: map['description'],
      analyzed: map['analyzed'] ?? false,
      analysisId: map['analysisId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileId': fileId,
      'caseId': caseId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'storagePath': storagePath,
      'uploadedAt': uploadedAt,
      'fileSizeBytes': fileSizeBytes,
      'fileType': fileType.toString().split('.').last,
      'description': description,
      'analyzed': analyzed,
      'analysisId': analysisId,
    };
  }

  @override
  List<Object?> get props => [
        fileId,
        caseId,
        fileName,
        fileUrl,
        storagePath,
        uploadedAt,
        fileSizeBytes,
        fileType,
        description,
        analyzed,
        analysisId,
      ];
}

enum STLFileType {
  alignerSetup,
  dentalModel,
  reference,
  other,
}

STLFileType _parseSTLFileType(String? type) {
  switch (type) {
    case 'alignerSetup':
      return STLFileType.alignerSetup;
    case 'dentalModel':
      return STLFileType.dentalModel;
    case 'reference':
      return STLFileType.reference;
    default:
      return STLFileType.other;
  }
}
