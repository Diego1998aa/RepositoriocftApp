import 'dart:async';
import 'dart:io';
import 'package:cftapp/modelos/coments.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modelos/event.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'my_app.db');
    return await openDatabase(
      path,
      version: 2, // Incrementa la versión cuando agregues nuevas tablas
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      type INTEGER NOT NULL,
      date TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE comments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      content TEXT NOT NULL
    )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL
      )
      ''');
    }
    // Agrega más migraciones aquí para versiones futuras
  }

  Future<int> insertEvent(Event event) async {
    try {
      Database db = await database;
      return await db.insert('events', event.toMap());
    } catch (e) {
      // Manejar error
      return -1; // Devuelve un id inválido para indicar un error
    }
  }

  Future<List<Event>> getEvents() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('events');
      return List.generate(maps.length, (i) {
        return Event(
          id: maps[i]['id'],
          title: maps[i]['title'],
          type: maps[i]['type'],
          date: DateTime.parse(maps[i]['date']),
        );
      });
    } catch (e) {
      // Manejar error
      return []; // Devuelve una lista vacía en caso de error
    }
  }

  Future<void> deleteAllEvents() async {
    try {
      Database db = await database;
      await db.delete('events');
    } catch (e) {
      // Manejar error
    }
  }

  Future<int> insertComment(Comment comment) async {
    try {
      Database db = await database;
      return await db.insert('comments', comment.toMap());
    } catch (e) {
      // Manejar error
      return -1; // Devuelve un id inválido para indicar un error
    }
  }

  Future<List<Comment>> getComments() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('comments');
      return List.generate(maps.length, (i) {
        return Comment(
          id: maps[i]['id'],
          content: maps[i]['content'],
        );
      });
    } catch (e) {
      // Manejar error
      return []; // Devuelve una lista vacía en caso de error
    }
  }

  Future<int> deleteComment(int id) async {
    try {
      Database db = await database;
      return await db.delete(
        'comments',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      // Manejar error
      return -1; // Devuelve un valor inválido en caso de error
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
