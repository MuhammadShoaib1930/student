import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:student/database/database_constants.dart';
import 'Student.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  // Private constructor for Singleton
  DatabaseService._();

  // Get the Singleton instance
  static Future<DatabaseService> getInstance() async {
    if (_instance == null) {
      _instance = DatabaseService._();
      await _instance!._initDatabase();
    }
    return _instance!;
  }

  // Initialize the database
  Future<void> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, DatabaseConstants.fileName);

    // Open the database and create the table
    _database = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE ${DatabaseConstants.tableName} (
          ${DatabaseConstants.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DatabaseConstants.name} TEXT,
          ${DatabaseConstants.phone} TEXT
        )
      ''');
    });
  }

  // Insert a student into the database
  Future<int> insertStudent(Student student) async {
    final db = await _database!;
    return await db.insert(DatabaseConstants.tableName, student.toMap());
  }

  // Update a student in the database
  Future<int> updateStudent(Student student) async {
    final db = await _database!;
    return await db.update(
      DatabaseConstants.tableName,
      student.toMap(),
      where: '${DatabaseConstants.id} = ?',
      whereArgs: [student.id],
    );
  }

  // Delete a student from the database
  Future<int> deleteStudent(int id) async {
    final db = await _database!;
    return await db.delete(
      DatabaseConstants.tableName,
      where: '${DatabaseConstants.id} = ?',
      whereArgs: [id],
    );
  }

  // Fetch all students from the database
  Future<List<Student>> getAllStudents() async {
    final db = await _database!;
    List<Map<String, dynamic>> maps = await db.query(DatabaseConstants.tableName);

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  // Search students by ID
  Future<Student?> searchById(int id) async {
    final db = await _database!;
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableName,
      where: '${DatabaseConstants.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  // Search students by name
  Future<List<Student>> searchByName(String name) async {
    final db = await _database!;
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableName,
      where: '${DatabaseConstants.name} LIKE ?',
      whereArgs: ['%$name%'],
    );

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  // Search students by phone
  Future<List<Student>> searchByPhone(String phone) async {
    final db = await _database!;
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableName,
      where: '${DatabaseConstants.phone} LIKE ?',
      whereArgs: ['%$phone%'],
    );

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  // Search students by combinations of ID, name, and phone
  Future<List<Student>> search({int? id, String? name, String? phone}) async {
    final db = await _database!;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (id != null) {
      whereClause += '${DatabaseConstants.id} = ?';
      whereArgs.add(id);
    }
    if (name != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '${DatabaseConstants.name} LIKE ?';
      whereArgs.add('%$name%');
    }
    if (phone != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '${DatabaseConstants.phone} LIKE ?';
      whereArgs.add('%$phone%');
    }

    List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableName,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  // Close the database connection
  Future<void> closeDatabase() async {
    final db = await _database!;
    await db.close();
  }
}
