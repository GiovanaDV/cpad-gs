import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/occurrence.dart';

abstract class OccurrenceRepository {
  Future<List<Occurrence>> getAll();
  Future<void> insert(Occurrence occurrence);

  /// SQLite em dispositivo; memória no Chrome (sqflite não roda na web).
  factory OccurrenceRepository.create() =>
      kIsWeb ? MemoryOccurrenceRepository() : SqliteOccurrenceRepository();
}

class MemoryOccurrenceRepository implements OccurrenceRepository {
  final List<Occurrence> _items = [];

  @override
  Future<List<Occurrence>> getAll() async => List.of(_items);

  @override
  Future<void> insert(Occurrence occurrence) async => _items.add(occurrence);
}

class SqliteOccurrenceRepository implements OccurrenceRepository {
  Database? _db;

  Future<Database> _open() async {
    return _db ??= await openDatabase(
      join(await getDatabasesPath(), 'nexo.db'),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE occurrences(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          sector TEXT NOT NULL,
          description TEXT NOT NULL,
          created_at TEXT NOT NULL,
          resolved_at TEXT,
          source TEXT NOT NULL
        )
      '''),
    );
  }

  @override
  Future<List<Occurrence>> getAll() async {
    final db = await _open();
    final rows = await db.query('occurrences', orderBy: 'created_at DESC');
    return rows.map(Occurrence.fromMap).toList();
  }

  @override
  Future<void> insert(Occurrence occurrence) async {
    final db = await _open();
    await db.insert('occurrences', occurrence.toMap()..remove('id'));
  }
}