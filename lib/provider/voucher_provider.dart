import 'package:flutter/material.dart';
import 'package:invoice_maker/database/voucher_db.dart';
import 'package:invoice_maker/model/voucher.dart';
import 'package:invoice_maker/model/voucher_item.dart';
import 'package:invoice_maker/provider/voucher_generator.dart';

class VoucherProvider extends ChangeNotifier {
  final VoucherDB _voucherDB = VoucherDB();
  final VoucherGenerator _generator = VoucherGenerator();

  List<VoucherItem> addedItems = [];
  List<Voucher> recentVouchers = [];
  bool isPDFLoading = false;

  double get totalIssuedNetWeight =>
      addedItems.fold(0.0, (sum, item) => sum + item.issuedNetWeight);

  String? validateField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  void addItem({
    required String itemName,
    required String hsnCode,
    required double issuedGrossWeight,
    required double touch,
    required double issuedNetWeight,
  }) {
    addedItems.add(
      VoucherItem(
        voucherId: -1,
        itemName: itemName,
        hsnCode: hsnCode,
        issuedGrossWeight: issuedGrossWeight,
        touch: touch,
        issuedNetWeight: issuedNetWeight,
      ),
    );
    notifyListeners();
  }

  void removeItem(VoucherItem item) {
    addedItems.remove(item);
    notifyListeners();
  }

  void replaceItem(
    VoucherItem oldItem, {
    required String itemName,
    required String hsnCode,
    required double issuedGrossWeight,
    required double touch,
    required double issuedNetWeight,
  }) {
    final index = addedItems.indexOf(oldItem);
    if (index == -1) return;
    addedItems[index] = oldItem.copyWith(
      itemName: itemName,
      hsnCode: hsnCode,
      issuedGrossWeight: issuedGrossWeight,
      touch: touch,
      issuedNetWeight: issuedNetWeight,
    );
    notifyListeners();
  }

  void clearItems() {
    addedItems.clear();
    notifyListeners();
  }

  Future<Voucher> addVoucher({
    required String name,
    required String gstin,
    required DateTime date,
    required List<VoucherItem> items,
  }) async {
    final double total = items.fold(0.0, (sum, i) => sum + i.issuedNetWeight);

    final voucher = Voucher(
      name: name,
      gstin: gstin,
      date: date,
      totalIssuedNetWeight: total,
    );

    final int voucherId = await _voucherDB.insertVoucher(voucher);

    for (final item in items) {
      await _voucherDB.insertVoucherItem(
        item.copyWith(voucherId: voucherId),
        voucherId,
      );
    }

    final saved = voucher.copyWith(voucherId: voucherId, items: items);
    addedItems.clear();
    notifyListeners();
    return saved;
  }

  Future<void> fetchVouchers() async {
    try {
      final vouchers = await _voucherDB.getVouchers();
      recentVouchers = vouchers;
      notifyListeners();
    } catch (e) {
      recentVouchers = [];
      notifyListeners();
    }
  }

  Future<void> loadVoucherForEditing(Voucher voucher) async {
    final items = await _voucherDB.getVoucherItems(voucher.voucherId!);
    addedItems = List<VoucherItem>.from(items);
    notifyListeners();
  }

  Future<void> updateVoucher({
    required int voucherId,
    required String name,
    required String gstin,
    required DateTime date,
    required List<VoucherItem> items,
  }) async {
    final double total = items.fold(0.0, (sum, i) => sum + i.issuedNetWeight);

    final voucher = Voucher(
      voucherId: voucherId,
      name: name,
      gstin: gstin,
      date: date,
      totalIssuedNetWeight: total,
    );

    await _voucherDB.updateVoucher(voucher);
    await _voucherDB.deleteVoucherItems(voucherId);

    for (final item in items) {
      await _voucherDB.insertVoucherItem(
        item.copyWith(voucherId: voucherId),
        voucherId,
      );
    }

    addedItems.clear();
    await fetchVouchers();
  }

  Future<void> generateVoucherPDF({
    required Voucher voucher,
    required BuildContext context,
    bool isShare = false,
  }) async {
    isPDFLoading = true;
    notifyListeners();
    try {
      final List<VoucherItem> items = await _voucherDB.getVoucherItems(
        voucher.voucherId!,
      );
      await _generator.createVoucher(
        voucherId: voucher.voucherId.toString(),
        name: voucher.name,
        gstin: voucher.gstin,
        date: voucher.date,
        items: items,
        isShare: isShare,
      );
    } catch (e) {
      throw Exception('Failed to generate voucher PDF: $e');
    } finally {
      isPDFLoading = false;
      notifyListeners();
    }
  }
}
