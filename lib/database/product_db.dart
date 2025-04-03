import 'package:invoice_maker/database/database_helper.dart';
import 'package:invoice_maker/model/product.dart';

class ProductDB {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertProduct(Product product, int invoiceId) async {
    final db = await _dbHelper.database;
    return await db.insert('products', {
      'invoice_id': invoiceId,
      'description': product.description,
      'hsn_code': product.hsnCode,
      'unit_of_measure': product.unitOfMeasure,
      'gross_weight': product.grossWeight,
      'stone_weight': product.stoneWeight,
      'net_weight': product.netWeight,
      'rate_per_gram': product.ratePerGram,
      'stone_charge': product.stoneCharge,
      'taxable_value': product.taxableValue,
    });
  }

  Future<int> deleteProduct(int productId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'products',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Product>> getProductsByInvoiceId(int invoiceId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }
}
