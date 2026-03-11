import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // ── Invoice keys ─────────────────────────────────────
  static const String _kInvGrossWt = 'inv_gross_wt_dp';
  static const String _kInvStoneWt = 'inv_stone_wt_dp';
  static const String _kInvNetWt = 'inv_net_wt_dp';
  static const String _kInvRate = 'inv_rate_dp';
  static const String _kInvStoneCharge = 'inv_stone_charge_dp';
  static const String _kInvTaxable = 'inv_taxable_dp';
  static const String _kInvAmounts = 'inv_amounts_dp';

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

    _vchIssuedGrossWtDp = prefs.getInt(_kVchIssuedGrossWt) ?? 3;
    _vchTouchDp = prefs.getInt(_kVchTouch) ?? 3;
    _vchIssuedNetWtDp = prefs.getInt(_kVchIssuedNetWt) ?? 3;
    notifyListeners();
  }

  Future<void> _save(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
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
