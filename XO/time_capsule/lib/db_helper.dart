import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'memory_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'memories.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE memories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        note TEXT,
        mood TEXT,
        photoPath TEXT,
        createdAt TEXT
      )
    ''');
  }

  Future<int> insertMemory(Memory memory) async {
    final db = await database;
    return await db.insert('memories', memory.toMap());
  }

  Future<List<Memory>> getAllMemories() async {
    final db = await database;
    final res = await db.query('memories', orderBy: 'id DESC');
    return res.map((e) => Memory.fromMap(e)).toList();
  }

  Future<int> updateMemory(Memory memory) async {
    final db = await database;
    return await db.update('memories', memory.toMap(),
        where: 'id = ?', whereArgs: [memory.id]);
  }

  Future<int> deleteMemory(int id) async {
    final db = await database;
    return await db.delete('memories', where: 'id = ?', whereArgs: [id]);
  }
}
