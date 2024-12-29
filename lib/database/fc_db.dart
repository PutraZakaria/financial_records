import 'package:sqflite/sqflite.dart';

class FRDB {
  final tableName = 'financialRecords';

  Future<void> createTable(Database database) async {
    await database.execute('''
      if exists DROP TABLE $tableName
      
      CREATE TABLE $tableName if not exists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        isIncome INTEGER NOT NULL,
        date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getRecords(Database database) async {
    return await database.query(tableName);
  }

  Future<void> createRecord(
      Database database, double amount, int isIncome, String date) async {
    await database.insert(tableName, {
      'amount': amount,
      'isIncome': isIncome,
      'date': date,
    });
  }

  Future<void> updateRecord(Database database, int id, double amount,
      int isIncome, String date) async {
    await database.update(
        tableName,
        {
          'amount': amount,
          'isIncome': isIncome,
          'date': date,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<void> deleteRecord(Database database, int id) async {
    await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
