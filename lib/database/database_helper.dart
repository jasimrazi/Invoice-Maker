import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'invoice_maker.db');
    print('Database path: $path'); // Debugging log

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) {
        print('Database opened'); // Debugging log
      },
    );
  }

   Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null; // Reset the database instance
      print('Database connection closed'); // Debugging log
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE recipients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  address TEXT,
  gstin TEXT,
  place TEXT
);

    ''');

    await db.execute('''
CREATE TABLE invoices (
  invoice_id INTEGER PRIMARY KEY AUTOINCREMENT,
  recipient_id INTEGER NOT NULL, -- Foreign key linking to recipients
  date TEXT NOT NULL,
  total_amount REAL NOT NULL,
  gst REAL NOT NULL,
  total_taxable_amount REAL NOT NULL,
  FOREIGN KEY (recipient_id) REFERENCES recipients (id) ON DELETE CASCADE
);
    ''');

    await db.execute('''
CREATE TABLE products (
  product_id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_id INTEGER NOT NULL, -- Foreign key linking to invoices
  description TEXT NOT NULL,
  hsn_code TEXT NOT NULL,
  unit_of_measure TEXT NOT NULL,
  gross_weight REAL NOT NULL,
  stone_weight REAL NOT NULL,
  net_weight REAL NOT NULL,
  rate_per_gram REAL NOT NULL,
  stone_charge REAL NOT NULL,
  taxable_value REAL NOT NULL,
  FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id) ON DELETE CASCADE
);
    ''');
  }
}
