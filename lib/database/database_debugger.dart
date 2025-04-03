import 'package:sqflite/sqflite.dart';
import 'database_helper.dart'; // Ensure this imports your DatabaseHelper class

class DatabaseDebugger {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get list of all tables in the database
  Future<void> listTables() async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    print("Tables in database: $tables");
  }

  // Get schema (columns) of a specific table
  Future<void> getTableSchema(String tableName) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> schema = await db.rawQuery(
      "PRAGMA table_info($tableName)",
    );
    print("Schema of $tableName: $schema");
  }

  // Fetch all rows from a given table
  Future<void> getAllRows(String tableName) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> rows = await db.query(tableName);
    print("Data in $tableName: $rows");
  }

  // Print the database path (useful for manual inspection)
  Future<void> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    print("Database path: $dbPath");
  }

  Future<void> debugInvoices() async {
    try {
      final db = await _dbHelper.database;

      // Execute the raw SQL query
      final List<Map<String, dynamic>> rows = await db.rawQuery(
        'SELECT * FROM invoices',
      );

      // Print each row
      for (final row in rows) {
        print('Invoice Row: $row');
      }
    } catch (e) {
      print('❌ Error fetching invoices for debugging: $e');
    }
  }
}
