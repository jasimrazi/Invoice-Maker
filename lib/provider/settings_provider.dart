import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String invoiceNumberNumeric = 'numeric';
  static const String invoiceNumberYearlyLetter = 'yearly_letter';

  // ── Invoice keys ─────────────────────────────────────
  static const String _kInvGrossWt = 'inv_gross_wt_dp';
  static const String _kInvStoneWt = 'inv_stone_wt_dp';
  static const String _kInvNetWt = 'inv_net_wt_dp';
  static const String _kInvRate = 'inv_rate_dp';
  static const String _kInvStoneCharge = 'inv_stone_charge_dp';
  static const String _kInvTaxable = 'inv_taxable_dp';
  static const String _kInvAmounts = 'inv_amounts_dp';
  static const String _kInvNumberFormat = 'inv_number_format';
  static const String _kInvNumberStartYear = 'inv_number_start_year';
  static const String _kInvNumberStartMonth = 'inv_number_start_month';

  // ── Voucher keys ────────────────────────────────────
  static const String _kVchIssuedGrossWt = 'vch_issued_gross_wt_dp';
  static const String _kVchTouch = 'vch_touch_dp';
  static const String _kVchIssuedNetWt = 'vch_issued_net_wt_dp';

  // ── Invoice state ───────────────────────────────────
  int _invGrossWtDp = 2;
  int _invStoneWtDp = 2;
  int _invNetWtDp = 2;
  int _invRateDp = 2;
  int _invStoneChargeDp = 2;
  int _invTaxableDp = 2;
  int _invAmountsDp = 2;
  String _invNumberFormat = invoiceNumberYearlyLetter;
  int _invNumberStartYear = 2026;
  int _invNumberStartMonth = 6;

  // ── Voucher state ──────────────────────────────────
  int _vchIssuedGrossWtDp = 3;
  int _vchTouchDp = 3;
  int _vchIssuedNetWtDp = 3;

  // ── Invoice getters ────────────────────────────────
  int get invGrossWtDp => _invGrossWtDp;
  int get invStoneWtDp => _invStoneWtDp;
  int get invNetWtDp => _invNetWtDp;
  int get invRateDp => _invRateDp;
  int get invStoneChargeDp => _invStoneChargeDp;
  int get invTaxableDp => _invTaxableDp;
  int get invAmountsDp => _invAmountsDp;
  String get invNumberFormat => _invNumberFormat;
  int get invNumberStartYear => _invNumberStartYear;
  int get invNumberStartMonth => _invNumberStartMonth;

  // ── Voucher getters ───────────────────────────────
  int get vchIssuedGrossWtDp => _vchIssuedGrossWtDp;
  int get vchTouchDp => _vchTouchDp;
  int get vchIssuedNetWtDp => _vchIssuedNetWtDp;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _invGrossWtDp = prefs.getInt(_kInvGrossWt) ?? 2;
    _invStoneWtDp = prefs.getInt(_kInvStoneWt) ?? 2;
    _invNetWtDp = prefs.getInt(_kInvNetWt) ?? 2;
    _invRateDp = prefs.getInt(_kInvRate) ?? 2;
    _invStoneChargeDp = prefs.getInt(_kInvStoneCharge) ?? 2;
    _invTaxableDp = prefs.getInt(_kInvTaxable) ?? 2;
    _invAmountsDp = prefs.getInt(_kInvAmounts) ?? 2;
    _invNumberFormat =
        prefs.getString(_kInvNumberFormat) ?? invoiceNumberYearlyLetter;
    _invNumberStartYear = prefs.getInt(_kInvNumberStartYear) ?? 2026;
    _invNumberStartMonth = prefs.getInt(_kInvNumberStartMonth) ?? 6;

    _vchIssuedGrossWtDp = prefs.getInt(_kVchIssuedGrossWt) ?? 3;
    _vchTouchDp = prefs.getInt(_kVchTouch) ?? 3;
    _vchIssuedNetWtDp = prefs.getInt(_kVchIssuedNetWt) ?? 3;
    notifyListeners();
  }

  Future<void> _save(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  String formatInvoiceNumber(int invoiceId, DateTime date) {
    if (_invNumberFormat == invoiceNumberNumeric) {
      return invoiceId.toString();
    }

    final cycle =
        (date.year - _invNumberStartYear) -
        (date.month < _invNumberStartMonth ? 1 : 0);
    final letterIndex = cycle < 0 ? 0 : cycle;
    final prefix = String.fromCharCode('A'.codeUnitAt(0) + letterIndex % 26);
    return '$prefix$invoiceId';
  }

  // ── Invoice setters ────────────────────────────────
  Future<void> setInvGrossWtDp(int v) async {
    _invGrossWtDp = v;
    notifyListeners();
    await _save(_kInvGrossWt, v);
  }

  Future<void> setInvStoneWtDp(int v) async {
    _invStoneWtDp = v;
    notifyListeners();
    await _save(_kInvStoneWt, v);
  }

  Future<void> setInvNetWtDp(int v) async {
    _invNetWtDp = v;
    notifyListeners();
    await _save(_kInvNetWt, v);
  }

  Future<void> setInvRateDp(int v) async {
    _invRateDp = v;
    notifyListeners();
    await _save(_kInvRate, v);
  }

  Future<void> setInvStoneChargeDp(int v) async {
    _invStoneChargeDp = v;
    notifyListeners();
    await _save(_kInvStoneCharge, v);
  }

  Future<void> setInvTaxableDp(int v) async {
    _invTaxableDp = v;
    notifyListeners();
    await _save(_kInvTaxable, v);
  }

  Future<void> setInvAmountsDp(int v) async {
    _invAmountsDp = v;
    notifyListeners();
    await _save(_kInvAmounts, v);
  }

  Future<void> setInvNumberFormat(String v) async {
    _invNumberFormat = v;
    notifyListeners();
    await _saveString(_kInvNumberFormat, v);
  }

  Future<void> setInvNumberStartYear(int v) async {
    _invNumberStartYear = v;
    notifyListeners();
    await _save(_kInvNumberStartYear, v);
  }

  Future<void> setInvNumberStartMonth(int v) async {
    _invNumberStartMonth = v;
    notifyListeners();
    await _save(_kInvNumberStartMonth, v);
  }

  // ── Voucher setters ──────────────────────────────
  Future<void> setVchIssuedGrossWtDp(int v) async {
    _vchIssuedGrossWtDp = v;
    notifyListeners();
    await _save(_kVchIssuedGrossWt, v);
  }

  Future<void> setVchTouchDp(int v) async {
    _vchTouchDp = v;
    notifyListeners();
    await _save(_kVchTouch, v);
  }

  Future<void> setVchIssuedNetWtDp(int v) async {
    _vchIssuedNetWtDp = v;
    notifyListeners();
    await _save(_kVchIssuedNetWt, v);
  }
}
