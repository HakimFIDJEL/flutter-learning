import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectoryException implements Exception {}

class NotesService {
  Database? _db;

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db == null) {
      return;
    }

    await _db!.close();
    _db = null;
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[userIdColumn] as int,
        email = map[userEmailColumn] as String;

  @override
  String toString() => 'DatabaseUser(id: $id, email: $email)';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[notesIdColumn] as int,
        userId = map[notesUserIdColumn] as int,
        text = map[notesTextColumn] as String,
        isSyncedWithCloud =
            (map[notesIsSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'DatabaseNote(id: $id, userId: $userId, isSyncedWithCloud: $isSyncedWithCloud)';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Database
const String dbName = 'learning_dart.db';
const String usersTable = 'user';
const String notesTable = 'note';

// Table user
const String userIdColumn = 'id';
const String userEmailColumn = 'email';

// Table note
const String notesIdColumn = 'id';
const String notesUserIdColumn = 'user_id';
const String notesTextColumn = 'text';
const String notesIsSyncedWithCloudColumn = 'is_synced_with_cloud';

// User table
const createUserTable = '''
  CREATE TABLE IF NOT EXISTS $usersTable (
    $userIdColumn INTEGER NOT NULL,
    $userEmailColumn TEXT NOT NULL,
    PRIMARY KEY ($userIdColumn AUTOINCREMENT)
  );
''';

// Note table
const createNoteTable = '''
  CREATE TABLE IF NOT EXISTS $notesTable (
    $notesIdColumn INTEGER NOT NULL,
    $notesUserIdColumn INTEGER NOT NULL,
    $notesTextColumn TEXT,
    $notesIsSyncedWithCloudColumn INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY ($notesUserIdColumn) REFERENCES $usersTable($userIdColumn),
    PRIMARY KEY ($notesIdColumn AUTOINCREMENT)
  );
''';
