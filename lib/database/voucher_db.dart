import 'package:invoice_maker/database/database_helper.dart';
import 'package:invoice_maker/model/voucher.dart';
import 'package:invoice_maker/model/voucher_item.dart';

class VoucherDB {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertVoucher(Voucher voucher) async {
    final db = await _dbHelper.database;
    return await db.insert('vouchers', {
      'name': voucher.name,
      'gstin': voucher.gstin,
      'date': voucher.date.toIso8601String(),
      'total_issued_net_weight': voucher.totalIssuedNetWeight,
    });
  }

  Future<List<Voucher>> getVouchers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('vouchers');
    return maps.map((map) => Voucher.fromMap(map)).toList();
  }

  Future<int> updateVoucher(Voucher voucher) async {
    final db = await _dbHelper.database;
    return await db.update(
      'vouchers',
      {
        'name': voucher.name,
        'gstin': voucher.gstin,
        'date': voucher.date.toIso8601String(),
        'total_issued_net_weight': voucher.totalIssuedNetWeight,
      },
      where: 'voucher_id = ?',
      whereArgs: [voucher.voucherId],
    );
  }

  Future<int> deleteVoucher(int voucherId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'vouchers',
      where: 'voucher_id = ?',
      whereArgs: [voucherId],
    );
  }

  Future<int> insertVoucherItem(VoucherItem item, int voucherId) async {
    final db = await _dbHelper.database;
    return await db.insert('voucher_items', {
      'voucher_id': voucherId,
      'material_type': item.materialType,
      'item_name': item.itemName,
      'hsn_code': item.hsnCode,
      'issued_gross_weight': item.issuedGrossWeight,
      'touch': item.touch,
      'issued_net_weight': item.issuedNetWeight,
    });
  }

  Future<List<VoucherItem>> getVoucherItems(int voucherId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'voucher_items',
      where: 'voucher_id = ?',
      whereArgs: [voucherId],
    );
    return maps.map((map) => VoucherItem.fromMap(map)).toList();
  }

  Future<int> deleteVoucherItems(int voucherId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'voucher_items',
      where: 'voucher_id = ?',
      whereArgs: [voucherId],
    );
  }
}
