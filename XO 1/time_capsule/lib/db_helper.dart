// lib/db_helper.dart

// ignore_for_file: unnecessary_cast

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'memory_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;
  static const int _dbVersion = 3; // keep version bumped for migrations

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'memories.db');
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        // Ensure the table & expected columns exist (helps when DB was created by older app)
        await _ensureTableAndColumns(db);
      },
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE memories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_email TEXT,
        title TEXT,
        note TEXT,
        mood TEXT,
        photoPath TEXT,
        createdAt TEXT
      )
    ''');
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add owner_email column if upgrading from older versions
    if (oldVersion < 3 && newVersion >= 3) {
      try {
        await db.execute('ALTER TABLE memories ADD COLUMN owner_email TEXT');
      } catch (_) {}
    }

    // Ensure photoPath exists for older versions as well
    try {
      await db.execute('ALTER TABLE memories ADD COLUMN photoPath TEXT');
    } catch (_) {}
  }

  /// Ensure table exists and that required columns are present.
  /// Adds missing columns (non-destructive ALTER TABLE).
  Future<void> _ensureTableAndColumns(Database db) async {
    // Check if table exists
    final tableInfo = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='memories'",
    );
    if (tableInfo.isEmpty) {
      // If table missing (very old DB), create it
      await _onCreate(db, _dbVersion);
      return;
    }

    // Read existing columns
    final pragma = await db.rawQuery("PRAGMA table_info('memories')");
    final existing = <String>{};
    for (final row in pragma) {
      final name = (row['name'] ?? row['NAME'] ?? row['Name'])?.toString();
      if (name != null) existing.add(name);
    }

    // Required columns and their add statements (if missing)
    final required = <String, String>{
      'owner_email': 'ALTER TABLE memories ADD COLUMN owner_email TEXT',
      'photoPath': 'ALTER TABLE memories ADD COLUMN photoPath TEXT',
      'createdAt': 'ALTER TABLE memories ADD COLUMN createdAt TEXT',
      'title': '', // title usually exists; empty => skip
      'note': '',
      'mood': '',
    };

    for (final entry in required.entries) {
      final col = entry.key;
      final alter = entry.value;
      if (!existing.contains(col)) {
        if (alter.isNotEmpty) {
          try {
            await db.execute(alter);
            debugPrint('DB migration: added column $col');
          } catch (e, st) {
            debugPrint('Failed to add column $col : $e');
            debugPrint('$st');
            // ignore and continue
          }
        }
      }
    }
  }

  /// Convert Memory object to a DB-friendly map.
  /// Ensures photoPaths is stored as JSON string under key 'photoPath'
  Map<String, dynamic> _memoryToDbMap(Memory memory) {
    final m = memory.toMap(); // memory.toMap already provides both forms
    // Ensure createdAt present
    if (!m.containsKey('createdAt') || m['createdAt'] == null || (m['createdAt'] as String).isEmpty) {
      m['createdAt'] = DateTime.now().toIso8601String();
    }

    // If photoPaths exists (List), ensure photoPath contains JSON string
    if (m.containsKey('photoPaths')) {
      final dynamic val = m['photoPaths'];
      try {
        if (val is List) {
          m['photoPath'] = jsonEncode(val);
        } else if (val is String) {
          m['photoPath'] = val;
        } else {
          m['photoPath'] = jsonEncode([]);
        }
      } catch (_) {
        m['photoPath'] = jsonEncode([]);
      }
      m.remove('photoPaths'); // DB stores under photoPath
    } else if (!m.containsKey('photoPath')) {
      m['photoPath'] = jsonEncode([]);
    }

    // Normalize owner_email key
    if (m.containsKey('ownerEmail') && !m.containsKey('owner_email')) {
      m['owner_email'] = m['ownerEmail'];
      m.remove('ownerEmail');
    }

    return m;
  }

  Future<int> insertMemory(Memory memory) async {
    final db = await database;
    try {
      // Safety: ensure columns present before inserting (in case migration didn't run)
      await _ensureTableAndColumns(db);

      final map = _memoryToDbMap(memory);
      final id = await db.insert('memories', map, conflictAlgorithm: ConflictAlgorithm.replace);
      return id;
    } catch (e, st) {
      debugPrint('DB insertMemory error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  /// Get all memories. If ownerEmail provided, returns only that user's memories.
  Future<List<Memory>> getAllMemories({String? ownerEmail}) async {
    final db = await database;
    // Ensure columns exist
    await _ensureTableAndColumns(db);

    List<Map<String, dynamic>> res;
    if (ownerEmail != null) {
      res = await db.query('memories', where: 'owner_email = ?', whereArgs: [ownerEmail], orderBy: 'id DESC');
    } else {
      res = await db.query('memories', orderBy: 'id DESC');
    }

    // Normalize each row to include 'photoPaths' as List<String>
    final List<Map<String, dynamic>> normalized = res.map((row) {
      final Map<String, dynamic> copy = Map<String, dynamic>.from(row);

      if (copy.containsKey('owner_email') && !copy.containsKey('ownerEmail')) {
        copy['ownerEmail'] = copy['owner_email'];
      }

      final dynamic pp = copy['photoPath'] ?? copy['photo_path'] ?? copy['photo_paths'] ?? copy['photoPaths'];
      if (pp == null) {
        copy['photoPaths'] = <String>[];
      } else if (pp is String) {
        try {
          final decoded = jsonDecode(pp);
          if (decoded is List) {
            copy['photoPaths'] = List<String>.from(decoded.map((e) => e?.toString() ?? ''));
          } else {
            copy['photoPaths'] = <String>[pp];
          }
        } catch (_) {
          final s = pp as String;
          if (s.contains(',')) {
            copy['photoPaths'] = s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          } else if (s.isEmpty) {
            copy['photoPaths'] = <String>[];
          } else {
            copy['photoPaths'] = <String>[s];
          }
        }
      } else if (pp is List) {
        copy['photoPaths'] = List<String>.from(pp.map((e) => e?.toString() ?? ''));
      } else {
        copy['photoPaths'] = <String>[];
      }

      return copy;
    }).toList();

    return normalized.map((e) => Memory.fromMap(e)).toList();
  }

  Future<List<Memory>> getAllMemoriesForEmail(String ownerEmail) => getAllMemories(ownerEmail: ownerEmail);

  Future<int> updateMemory(Memory memory) async {
    final db = await database;
    await _ensureTableAndColumns(db);
    final map = _memoryToDbMap(memory);
    final id = memory.id;
    if (id == null) {
      throw ArgumentError('Memory id is null for update');
    }
    return await db.update('memories', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMemory(int id) async {
    final db = await database;
    return await db.delete('memories', where: 'id = ?', whereArgs: [id]);
  }

  /// Optional helper: get memory by id and owner email to ensure correct ownership
  Future<Memory?> getMemoryByIdForEmail(int id, String ownerEmail) async {
    final db = await database;
    await _ensureTableAndColumns(db);
    final res = await db.query('memories', where: 'id = ? AND owner_email = ?', whereArgs: [id, ownerEmail], limit: 1);
    if (res.isEmpty) return null;

    final Map<String, dynamic> row = Map<String, dynamic>.from(res.first);

    final dynamic pp = row['photoPath'] ?? row['photo_path'] ?? row['photo_paths'] ?? row['photoPaths'];
    if (pp == null) {
      row['photoPaths'] = <String>[];
    } else if (pp is String) {
      try {
        final decoded = jsonDecode(pp);
        if (decoded is List) {
          row['photoPaths'] = List<String>.from(decoded.map((e) => e?.toString() ?? ''));
        } else {
          row['photoPaths'] = <String>[pp];
        }
      } catch (_) {
        final s = pp as String;
        if (s.contains(',')) {
          row['photoPaths'] = s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        } else if (s.isEmpty) {
          row['photoPaths'] = <String>[];
        } else {
          row['photoPaths'] = <String>[s];
        }
      }
    } else if (pp is List) {
      row['photoPaths'] = List<String>.from(pp.map((e) => e?.toString() ?? ''));
    } else {
      row['photoPaths'] = <String>[];
    }

    if (row.containsKey('owner_email') && !row.containsKey('ownerEmail')) {
      row['ownerEmail'] = row['owner_email'];
    }

    return Memory.fromMap(row);
  }
}