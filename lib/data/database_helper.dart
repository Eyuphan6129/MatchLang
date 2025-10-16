import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('userdata.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 9,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        coins INTEGER NOT NULL,
        hearts INTEGER NOT NULL,
        stars INTEGER NOT NULL,
        current_level INTEGER NOT NULL,
        daily_gift_taken INTEGER NOT NULL DEFAULT 0,
        avatar TEXT,
        last_daily_gift_time TEXT,
        last_heart_time TEXT,
        last_wheel_spin_time TEXT,
        is_sound_on INTEGER NOT NULL DEFAULT 1,
        is_vibration_on INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        correct_answers INTEGER NOT NULL DEFAULT 0,
        incorrect_answers INTEGER NOT NULL DEFAULT 0,
        UNIQUE(user_id, date)
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      await db.execute(
        'ALTER TABLE user_data ADD COLUMN last_wheel_spin_time TEXT',
      );
    }
    if (oldVersion < 7) {
      await db.execute(
        'ALTER TABLE user_data ADD COLUMN is_sound_on INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE user_data ADD COLUMN is_vibration_on INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_stats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          date TEXT NOT NULL,
          correct_answers INTEGER NOT NULL DEFAULT 0,
          incorrect_answers INTEGER NOT NULL DEFAULT 0,
          UNIQUE(user_id, date)
        )
      ''');
    }
    if (oldVersion < 9) {
      await db.execute(
        "ALTER TABLE user_data ADD COLUMN display_name TEXT NOT NULL DEFAULT 'Kullanıcı'",
      );
    }
  }

  Future<void> insertOrUpdateUserData({
    required String userId,
    required String displayName,
    required int coins,
    required int hearts,
    required int stars,
    required int currentLevel,
    int dailyGiftTaken = 0,
    String? avatar,
    String? lastDailyGiftTime,
    String? lastHeartTime,
    String? lastWheelSpinTime,
    required bool isSoundOn,
    required bool isVibrationOn,
  }) async {
    final db = await instance.database;

    final data = {
      'display_name': displayName,
      'coins': coins,
      'hearts': hearts,
      'stars': stars,
      'current_level': currentLevel,
      'daily_gift_taken': dailyGiftTaken,
      'avatar': avatar,
      'last_daily_gift_time': lastDailyGiftTime,
      'last_heart_time': lastHeartTime,
      'last_wheel_spin_time': lastWheelSpinTime,
      'is_sound_on': isSoundOn ? 1 : 0,
      'is_vibration_on': isVibrationOn ? 1 : 0,
    };

    final existing = await db.query(
      'user_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (existing.isEmpty) {
      await db.insert('user_data', {'user_id': userId, ...data});
    } else {
      await db.update(
        'user_data',
        data,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final db = await instance.database;
    final results = await db.query(
      'user_data',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }

  Future<Map<String, dynamic>?> getDailyStats(
    String userId,
    String date,
  ) async {
    final db = await instance.database;
    final results = await db.query(
      'daily_stats',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      limit: 1,
    );
    if (results.isNotEmpty) return results.first;

    await db.insert('daily_stats', {'user_id': userId, 'date': date});
    return getDailyStats(userId, date);
  }

  Future<void> updateDailyStats(String userId, bool wasCorrect) async {
    final db = await instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    await getDailyStats(userId, today);

    final columnToUpdate = wasCorrect ? 'correct_answers' : 'incorrect_answers';
    await db.rawUpdate(
      '''
      UPDATE daily_stats 
      SET $columnToUpdate = $columnToUpdate + 1 
      WHERE user_id = ? AND date = ?
    ''',
      [userId, today],
    );
  }

  Future<void> deleteUser(String userId) async {
    final db = await instance.database;
    await db.delete('user_data', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('daily_stats', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
