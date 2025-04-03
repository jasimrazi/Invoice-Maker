import 'package:invoice_maker/database/database_helper.dart';
import 'package:invoice_maker/model/invoice.dart';

class InvoiceDB {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertInvoice(Invoice invoice, int recipientId) async {
    final db = await _dbHelper.database;
    return await db.insert('invoices', {
      'recipient_id': recipientId,
      'date': invoice.date.toIso8601String(),
      'total_amount': invoice.totalAmount,
      'gst': invoice.gst,
      'total_taxable_amount': invoice.totalTaxableAmount,
    });
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('invoices');
    return maps.map((map) => Invoice.fromMap(map)).toList();
  }
}
