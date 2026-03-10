import 'package:invoice_maker/model/voucher_item.dart';

class Voucher {
  final int? voucherId;
  final String name;
  final String gstin;
  final DateTime date;
  final double totalIssuedNetWeight;
  final List<VoucherItem> items;

  Voucher({
    this.voucherId,
    required this.name,
    required this.gstin,
    required this.date,
    required this.totalIssuedNetWeight,
    this.items = const [],
  });

  factory Voucher.fromMap(Map<String, dynamic> map) => Voucher(
    voucherId: map['voucher_id'] as int?,
    name: map['name'] ?? '',
    gstin: map['gstin'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    totalIssuedNetWeight:
        (map['total_issued_net_weight'] as num?)?.toDouble() ?? 0.0,
    items: [],
  );

  Voucher copyWith({
    int? voucherId,
    String? name,
    String? gstin,
    DateTime? date,
    double? totalIssuedNetWeight,
    List<VoucherItem>? items,
  }) => Voucher(
    voucherId: voucherId ?? this.voucherId,
    name: name ?? this.name,
    gstin: gstin ?? this.gstin,
    date: date ?? this.date,
    totalIssuedNetWeight: totalIssuedNetWeight ?? this.totalIssuedNetWeight,
    items: items ?? this.items,
  );
}
