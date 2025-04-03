class Product {
  int? productId; // Nullable because it will be auto-generated
  final int invoiceId; // Link to the invoice
  final String description;
  final String hsnCode;
  final String unitOfMeasure;
  final double grossWeight;
  final double? stoneWeight; // Nullable
  final double netWeight;
  final double ratePerGram;
  final double? stoneCharge; // Nullable
  final double taxableValue;

  Product({
    this.productId,
    required this.invoiceId,
    required this.description,
    required this.hsnCode,
    required this.unitOfMeasure,
    required this.grossWeight,
    this.stoneWeight = 0.0,
    required this.netWeight,
    required this.ratePerGram,
    this.stoneCharge = 0.0,
    required this.taxableValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'invoice_id': invoiceId,
      'description': description,
      'hsn_code': hsnCode,
      'unit_of_measure': unitOfMeasure,
      'gross_weight': grossWeight,
      'stone_weight': stoneWeight,
      'net_weight': netWeight,
      'rate_per_gram': ratePerGram,
      'stone_charge': stoneCharge,
      'taxable_value': taxableValue,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['product_id'] as int?,
      invoiceId: map['invoice_id'] as int,
      description: map['description'] ?? 'Unknown',
      hsnCode: map['hsn_code'] ?? 'Unknown',
      unitOfMeasure: map['unit_of_measure'] ?? 'Unknown',
      grossWeight: (map['gross_weight'] as num).toDouble(),
      stoneWeight: (map['stone_weight'] as num?)?.toDouble() ?? 0.0,
      netWeight: (map['net_weight'] as num).toDouble(),
      ratePerGram: (map['rate_per_gram'] as num).toDouble(),
      stoneCharge: (map['stone_charge'] as num?)?.toDouble() ?? 0.0,
      taxableValue: (map['taxable_value'] as num).toDouble(),
    );
  }

  // Adding the copyWith method
  Product copyWith({
    int? productId,
    int? invoiceId,
    String? description,
    String? hsnCode,
    String? unitOfMeasure,
    double? grossWeight,
    double? stoneWeight,
    double? netWeight,
    double? ratePerGram,
    double? stoneCharge,
    double? taxableValue,
  }) {
    return Product(
      productId: productId ?? this.productId, // Keep current value if null
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      hsnCode: hsnCode ?? this.hsnCode,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      grossWeight: grossWeight ?? this.grossWeight,
      stoneWeight: stoneWeight ?? this.stoneWeight,
      netWeight: netWeight ?? this.netWeight,
      ratePerGram: ratePerGram ?? this.ratePerGram,
      stoneCharge: stoneCharge ?? this.stoneCharge,
      taxableValue: taxableValue ?? this.taxableValue,
    );
  }
}
