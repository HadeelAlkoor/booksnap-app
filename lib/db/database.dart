import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("booksnap.db");
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // إنشاء الجداول
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE summaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        imagePath TEXT,
        originalText TEXT,
        summaryText TEXT,
        createdAt TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  // ============================
  //       عمليات المستخدمين
  // ============================

  // إضافة مستخدم جديد (للRegister)
  Future<int> registerUser(String name, String email, String password) async {
    final db = await instance.database;

    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  // التحقق من تسجيل الدخول (Login)
  Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // ============================
  //       عمليات الملخصات
  // ============================

  // إضافة ملخص جديد
  Future<int> addSummary({
    required int userId,
    required String imagePath,
    required String originalText,
    required String summaryText,
  }) async {
    final db = await instance.database;

    return await db.insert('summaries', {
      'user_id': userId,
      'imagePath': imagePath,
      'originalText': originalText,
      'summaryText': summaryText,
      'createdAt': DateTime.now().toString(),
    });
  }

  // جلب الملخصات الخاصة بمستخدم واحد
  Future<List<Map<String, dynamic>>> getUserSummaries(int userId) async {
    final db = await instance.database;

    return await db.query(
      'summaries',
      where: "user_id = ?",
      whereArgs: [userId],
      orderBy: "id DESC",
    );
  }

  // جلب ملخص واحد بالتفصيل
  Future<Map<String, dynamic>?> getSummary(int id) async {
    final db = await instance.database;

    final result = await db.query(
      'summaries',
      where: "id = ?",
      whereArgs: [id],
    );

    if (result.isNotEmpty) return result.first;
    return null;
  }

  // حذف ملخص
  Future<int> deleteSummary(int id) async {
    final db = await instance.database;

    return await db.delete(
      'summaries',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}