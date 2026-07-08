import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import '../models/models.dart';

/// SQLite local database — primary offline store on mobile/desktop.
/// On web (kIsWeb) all methods are no-ops; Firestore is used exclusively.
class DatabaseService {
  static const String _dbName = 'ai_orthodontic.db';
  static const int _dbVersion = 1;

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  // ── INIT ──────────────────────────────────────────────────────────────────

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE users (
        id           TEXT    PRIMARY KEY,
        email        TEXT    NOT NULL UNIQUE,
        name         TEXT    NOT NULL,
        role         TEXT    NOT NULL DEFAULT 'doctor',
        image_url    TEXT,
        specialization TEXT,
        license_no   TEXT,
        email_verified INTEGER DEFAULT 0,
        created_at   INTEGER NOT NULL,
        updated_at   INTEGER NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE cases (
        case_id           TEXT    PRIMARY KEY,
        user_id           TEXT    NOT NULL,
        patient_id        TEXT    NOT NULL,
        patient_name      TEXT    NOT NULL,
        case_title        TEXT    NOT NULL,
        description       TEXT,
        status            TEXT    NOT NULL DEFAULT 'active',
        stl_file_ids      TEXT    NOT NULL DEFAULT '[]',
        latest_analysis_id TEXT,
        total_analyses    INTEGER NOT NULL DEFAULT 0,
        created_at        INTEGER NOT NULL,
        updated_at        INTEGER NOT NULL,
        is_synced         INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    batch.execute('''
      CREATE TABLE stl_files (
        file_id       TEXT    PRIMARY KEY,
        case_id       TEXT    NOT NULL,
        file_name     TEXT    NOT NULL,
        file_url      TEXT    NOT NULL DEFAULT '',
        storage_path  TEXT    NOT NULL DEFAULT '',
        file_size     REAL    NOT NULL DEFAULT 0,
        file_type     TEXT    NOT NULL DEFAULT 'other',
        description   TEXT,
        analyzed      INTEGER NOT NULL DEFAULT 0,
        analysis_id   TEXT,
        uploaded_at   INTEGER NOT NULL,
        is_synced     INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(case_id) REFERENCES cases(case_id)
      )
    ''');

    batch.execute('''
      CREATE TABLE analyses (
        analysis_id      TEXT    PRIMARY KEY,
        case_id          TEXT    NOT NULL,
        stl_file_id      TEXT    NOT NULL,
        analysis_type    TEXT    NOT NULL,
        result_json      TEXT    NOT NULL DEFAULT '{}',
        effectiveness    REAL,
        predictability   REAL,
        created_at       INTEGER NOT NULL,
        is_synced        INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(case_id) REFERENCES cases(case_id)
      )
    ''');

    batch.execute('''
      CREATE TABLE sync_queue (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type   TEXT    NOT NULL,
        entity_id     TEXT    NOT NULL,
        operation     TEXT    NOT NULL,
        payload       TEXT    NOT NULL DEFAULT '{}',
        created_at    INTEGER NOT NULL,
        retries       INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await batch.commit(noResult: true);
  }

  // ── USER CRUD ─────────────────────────────────────────────────────────────

  Future<void> upsertUser(UserModel u) async {
    if (kIsWeb) return;
    final d = await db;
    await d.insert(
      'users',
      {
        'id': u.uid,
        'email': u.email,
        'name': u.name,
        'role': u.role.name,
        'image_url': u.profileImageUrl,
        'specialization': u.specialization,
        'license_no': u.licenseNumber,
        'email_verified': (u.isEmailVerified ?? false) ? 1 : 0,
        'created_at': u.createdAt.millisecondsSinceEpoch,
        'updated_at': u.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUserById(String uid) async {
    if (kIsWeb) return null;
    final d = await db;
    final rows = await d.query('users', where: 'id = ?', whereArgs: [uid]);
    if (rows.isEmpty) return null;
    return _userFromRow(rows.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    if (kIsWeb) return null;
    final d = await db;
    final rows = await d.query('users', where: 'email = ?', whereArgs: [email]);
    if (rows.isEmpty) return null;
    return _userFromRow(rows.first);
  }

  Future<void> deleteUser(String uid) async {
    if (kIsWeb) return;
    final d = await db;
    await d.delete('users', where: 'id = ?', whereArgs: [uid]);
  }

  UserModel _userFromRow(Map<String, dynamic> r) => UserModel(
        uid: r['id'] as String,
        email: r['email'] as String,
        name: r['name'] as String,
        role: UserRole.values.firstWhere((v) => v.name == r['role'],
            orElse: () => UserRole.doctor),
        profileImageUrl: r['image_url'] as String?,
        specialization: r['specialization'] as String?,
        licenseNumber: r['license_no'] as String?,
        isEmailVerified: (r['email_verified'] as int) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(r['updated_at'] as int),
      );

  // ── CASE CRUD ─────────────────────────────────────────────────────────────

  Future<void> upsertCase(CaseModel c) async {
    if (kIsWeb) return;
    final d = await db;
    await d.insert(
      'cases',
      {
        'case_id': c.caseId,
        'user_id': c.userId,
        'patient_id': c.patientId,
        'patient_name': c.patientName,
        'case_title': c.caseTitle,
        'description': c.description,
        'status': c.status.toString().split('.').last,
        'stl_file_ids': jsonEncode(c.stlFileIds),
        'latest_analysis_id': c.latestAnalysisId,
        'total_analyses': c.totalAnalyses,
        'created_at': c.createdAt.millisecondsSinceEpoch,
        'updated_at': c.updatedAt.millisecondsSinceEpoch,
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CaseModel>> getCasesByUser(String userId) async {
    if (kIsWeb) return [];
    final d = await db;
    final rows = await d.query(
      'cases',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
    return rows.map(_caseFromRow).toList();
  }

  Future<CaseModel?> getCaseById(String caseId) async {
    if (kIsWeb) return null;
    final d = await db;
    final rows =
        await d.query('cases', where: 'case_id = ?', whereArgs: [caseId]);
    if (rows.isEmpty) return null;
    return _caseFromRow(rows.first);
  }

  Future<void> deleteCase(String caseId) async {
    if (kIsWeb) return;
    final d = await db;
    final batch = d.batch();
    batch.delete('cases', where: 'case_id = ?', whereArgs: [caseId]);
    batch.delete('stl_files', where: 'case_id = ?', whereArgs: [caseId]);
    batch.delete('analyses', where: 'case_id = ?', whereArgs: [caseId]);
    await batch.commit(noResult: true);
  }

  CaseModel _caseFromRow(Map<String, dynamic> r) => CaseModel(
        caseId: r['case_id'] as String,
        userId: r['user_id'] as String,
        patientId: r['patient_id'] as String,
        patientName: r['patient_name'] as String,
        caseTitle: r['case_title'] as String,
        description: r['description'] as String?,
        status: _parseCaseStatus(r['status'] as String),
        stlFileIds:
            List<String>.from(jsonDecode(r['stl_file_ids'] as String)),
        latestAnalysisId: r['latest_analysis_id'] as String?,
        totalAnalyses: r['total_analyses'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(r['updated_at'] as int),
      );

  CaseStatus _parseCaseStatus(String s) {
    switch (s) {
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

  // ── STL FILE CRUD ─────────────────────────────────────────────────────────

  Future<void> upsertSTLFile(STLFileModel f) async {
    if (kIsWeb) return;
    final d = await db;
    await d.insert(
      'stl_files',
      {
        'file_id': f.fileId,
        'case_id': f.caseId,
        'file_name': f.fileName,
        'file_url': f.fileUrl,
        'storage_path': f.storagePath,
        'file_size': f.fileSizeBytes,
        'file_type': f.fileType.toString().split('.').last,
        'description': f.description,
        'analyzed': f.analyzed ? 1 : 0,
        'analysis_id': f.analysisId,
        'uploaded_at': f.uploadedAt.millisecondsSinceEpoch,
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<STLFileModel>> getSTLFilesByCase(String caseId) async {
    if (kIsWeb) return [];
    final d = await db;
    final rows = await d.query(
      'stl_files',
      where: 'case_id = ?',
      whereArgs: [caseId],
      orderBy: 'uploaded_at DESC',
    );
    return rows.map(_stlFromRow).toList();
  }

  Future<void> deleteSTLFile(String fileId) async {
    if (kIsWeb) return;
    final d = await db;
    await d.delete('stl_files', where: 'file_id = ?', whereArgs: [fileId]);
  }

  STLFileModel _stlFromRow(Map<String, dynamic> r) => STLFileModel(
        fileId: r['file_id'] as String,
        caseId: r['case_id'] as String,
        fileName: r['file_name'] as String,
        fileUrl: r['file_url'] as String,
        storagePath: r['storage_path'] as String,
        fileSizeBytes: (r['file_size'] as num).toDouble(),
        fileType: _parseSTLType(r['file_type'] as String),
        description: r['description'] as String?,
        analyzed: (r['analyzed'] as int) == 1,
        analysisId: r['analysis_id'] as String?,
        uploadedAt:
            DateTime.fromMillisecondsSinceEpoch(r['uploaded_at'] as int),
      );

  STLFileType _parseSTLType(String s) {
    switch (s) {
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

  // ── STATS ─────────────────────────────────────────────────────────────────

  Future<Map<String, int>> getCaseStats(String userId) async {
    if (kIsWeb) {
      return {'total': 0, 'active': 0, 'completed': 0, 'in_review': 0, 'analyzed': 0};
    }
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT
        COUNT(*)                                                    AS total,
        SUM(CASE WHEN status = 'active'    THEN 1 ELSE 0 END)      AS active,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END)      AS completed,
        SUM(CASE WHEN status = 'inReview'  THEN 1 ELSE 0 END)      AS in_review,
        SUM(CASE WHEN latest_analysis_id IS NOT NULL THEN 1 ELSE 0 END) AS analyzed
      FROM cases WHERE user_id = ?
    ''', [userId]);

    if (rows.isEmpty) {
      return {'total': 0, 'active': 0, 'completed': 0, 'in_review': 0, 'analyzed': 0};
    }
    final r = rows.first;
    return {
      'total': (r['total'] as int?) ?? 0,
      'active': (r['active'] as int?) ?? 0,
      'completed': (r['completed'] as int?) ?? 0,
      'in_review': (r['in_review'] as int?) ?? 0,
      'analyzed': (r['analyzed'] as int?) ?? 0,
    };
  }

  // ── SYNC QUEUE ────────────────────────────────────────────────────────────

  Future<void> enqueueSync({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    if (kIsWeb) return;
    final d = await db;
    await d.insert('sync_queue', {
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    if (kIsWeb) return [];
    final d = await db;
    return d.query('sync_queue', orderBy: 'created_at ASC', limit: 50);
  }

  Future<void> removeSyncItem(int id) async {
    if (kIsWeb) return;
    final d = await db;
    await d.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  // ── CLEANUP ───────────────────────────────────────────────────────────────

  Future<void> clearAllData() async {
    if (kIsWeb) return;
    final d = await db;
    final batch = d.batch();
    for (final table in ['analyses', 'stl_files', 'cases', 'users', 'sync_queue']) {
      batch.delete(table);
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    if (kIsWeb) return;
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
