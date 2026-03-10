class VoucherItem {
  int? itemId;
  final int voucherId;
  final String itemName;
  final String hsnCode;
  final double issuedGrossWeight;
  final double touch;
  final double issuedNetWeight;

  VoucherItem({
    this.itemId,
    required this.voucherId,
    required this.itemName,
    required this.hsnCode,
    required this.issuedGrossWeight,
    required this.touch,
    required this.issuedNetWeight,
  });

  Map<String, dynamic> toMap() => {
    'item_id': itemId,
    'voucher_id': voucherId,
    'item_name': itemName,
    'hsn_code': hsnCode,
    'issued_gross_weight': issuedGrossWeight,
    'touch': touch,
    'issued_net_weight': issuedNetWeight,
  };

  factory VoucherItem.fromMap(Map<String, dynamic> map) => VoucherItem(
    itemId: map['item_id'] as int?,
    voucherId: map['voucher_id'] as int,
    itemName: map['item_name'] ?? '',
    hsnCode: map['hsn_code'] ?? '',
    issuedGrossWeight: (map['issued_gross_weight'] as num).toDouble(),
    touch: (map['touch'] as num).toDouble(),
    issuedNetWeight: (map['issued_net_weight'] as num).toDouble(),
  );

  VoucherItem copyWith({
    int? itemId,
    int? voucherId,
    String? itemName,
    String? hsnCode,
    double? issuedGrossWeight,
    double? touch,
    double? issuedNetWeight,
  }) => VoucherItem(
    itemId: itemId ?? this.itemId,
    voucherId: voucherId ?? this.voucherId,
    itemName: itemName ?? this.itemName,
    hsnCode: hsnCode ?? this.hsnCode,
    issuedGrossWeight: issuedGrossWeight ?? this.issuedGrossWeight,
    touch: touch ?? this.touch,
    issuedNetWeight: issuedNetWeight ?? this.issuedNetWeight,
  );
}
