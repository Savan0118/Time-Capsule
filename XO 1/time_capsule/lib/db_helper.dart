// lib/db_helper.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'memory_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;
  static const int _dbVersion = 3; // bumped to 3 for owner_email migration

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'memories.db');
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
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
      } catch (_) {
        // ignore if column already exists
      }
    }
    // previous migration from v1->v2 (user_id) may also exist in your app;
    // this onUpgrade assumes we are now at version 3 (owner_email). Adjust if your DB versions differ.
  }

  Future<int> insertMemory(Memory memory) async {
    final db = await database;
    return await db.insert('memories', memory.toMap());
  }

  /// Get all memories. If ownerEmail provided, returns only that user's memories.
  Future<List<Memory>> getAllMemories({String? ownerEmail}) async {
    final db = await database;
    List<Map<String, dynamic>> res;
    if (ownerEmail != null) {
      res = await db.query('memories', where: 'owner_email = ?', whereArgs: [ownerEmail], orderBy: 'id DESC');
    } else {
      res = await db.query('memories', orderBy: 'id DESC');
    }
    return res.map((e) => Memory.fromMap(e)).toList();
  }

  Future<List<Memory>> getAllMemoriesForEmail(String ownerEmail) => getAllMemories(ownerEmail: ownerEmail);

  Future<int> updateMemory(Memory memory) async {
    final db = await database;
    return await db.update('memories', memory.toMap(), where: 'id = ?', whereArgs: [memory.id]);
  }

  Future<int> deleteMemory(int id) async {
    final db = await database;
    return await db.delete('memories', where: 'id = ?', whereArgs: [id]);
  }

  /// Optional helper: get memory by id and owner email to ensure correct ownership
  Future<Memory?> getMemoryByIdForEmail(int id, String ownerEmail) async {
    final db = await database;
    final res = await db.query('memories', where: 'id = ? AND owner_email = ?', whereArgs: [id, ownerEmail], limit: 1);
    if (res.isEmpty) return null;
    return Memory.fromMap(res.first);
  }
}
