import 'package:invoice_maker/database/database_helper.dart';
import 'package:invoice_maker/model/recipient.dart';

class RecipientDB {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertRecipient(Recipient recipient) async {
    final db = await _dbHelper.database;
    return await db.insert('recipients', recipient.toMap());
  }

  Future<List<Recipient>> getRecipients() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('recipients');
    print('Fetched recipients from DB: $maps'); // Debug log
    return maps.map((map) => Recipient.fromMap(map)).toList();
  }

  Future<Recipient?> getRecipientById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Recipient.fromMap(maps.first);
    }
    return null; // Return null if no recipient is found
  }

  Future<int> updateRecipient(Recipient recipient, int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'recipients',
      recipient.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecipient(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('recipients', where: 'id = ?', whereArgs: [id]);
  }
}
