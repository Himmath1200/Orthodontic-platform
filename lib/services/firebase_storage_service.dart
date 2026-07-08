import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../config/firebase_config.dart';

/// Handles uploading/downloading files to Firebase Storage.
/// STL files are stored at: stl_files/{userId}/{caseId}/{filename}
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── STL FILE UPLOAD ────────────────────────────────────────────────────────

  /// Uploads a local STL file and returns (downloadUrl, storagePath).
  Future<({String downloadUrl, String storagePath})> uploadSTLFile({
    required File file,
    required String userId,
    required String caseId,
    required String fileId,
    void Function(double progress)? onProgress,
  }) async {
    final ext = p.extension(file.path).toLowerCase();
    final fileName = '$fileId$ext';
    final storagePath =
        '${FirebaseConfig.stlStoragePath}/$userId/$caseId/$fileName';

    final ref = _storage.ref(storagePath);
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: 'model/stl',
        customMetadata: {
          'userId': userId,
          'caseId': caseId,
          'fileId': fileId,
        },
      ),
    );

    // Stream progress events
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });
    }

    await uploadTask;
    final downloadUrl = await ref.getDownloadURL();
    return (downloadUrl: downloadUrl, storagePath: storagePath);
  }

  /// Upload from bytes (e.g. web platform picked file).
  Future<({String downloadUrl, String storagePath})> uploadSTLBytes({
    required List<int> bytes,
    required String userId,
    required String caseId,
    required String fileId,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final ext = p.extension(fileName).toLowerCase();
    final storageName = '$fileId$ext';
    final storagePath =
        '${FirebaseConfig.stlStoragePath}/$userId/$caseId/$storageName';

    final ref = _storage.ref(storagePath);
    final uploadTask = ref.putData(
      bytes as dynamic,
      SettableMetadata(contentType: 'model/stl'),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });
    }

    await uploadTask;
    final downloadUrl = await ref.getDownloadURL();
    return (downloadUrl: downloadUrl, storagePath: storagePath);
  }

  // ── PROFILE IMAGE UPLOAD ───────────────────────────────────────────────────

  Future<String> uploadProfileImage({
    required File image,
    required String userId,
  }) async {
    final storagePath =
        '${FirebaseConfig.profileImagesPath}/$userId/avatar.jpg';
    final ref = _storage.ref(storagePath);
    await ref.putFile(
      image,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  // ── DOWNLOAD ───────────────────────────────────────────────────────────────

  Future<String> getDownloadUrl(String storagePath) async {
    return _storage.ref(storagePath).getDownloadURL();
  }

  Future<void> downloadFile({
    required String storagePath,
    required String localPath,
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref(storagePath);
    final downloadTask = ref.writeToFile(File(localPath));

    if (onProgress != null) {
      downloadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });
    }

    await downloadTask;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } on FirebaseException catch (e) {
      // Ignore "object not found" — already deleted
      if (e.code != 'object-not-found') rethrow;
    }
  }

  /// Delete all STL files for a case.
  Future<void> deleteCaseFiles({
    required String userId,
    required String caseId,
  }) async {
    final prefix =
        '${FirebaseConfig.stlStoragePath}/$userId/$caseId/';
    try {
      final listResult = await _storage.ref(prefix).listAll();
      await Future.wait(listResult.items.map((item) => item.delete()));
    } on FirebaseException catch (_) {
      // Folder may not exist — that's fine
    }
  }

  // ── METADATA ──────────────────────────────────────────────────────────────

  Future<FullMetadata> getFileMetadata(String storagePath) async {
    return _storage.ref(storagePath).getMetadata();
  }
}
