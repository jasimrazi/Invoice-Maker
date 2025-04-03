import 'package:invoice_maker/model/product.dart';
import 'package:invoice_maker/model/recipient.dart';

class Invoice {
  final int? invoiceId;
  final Recipient recipient;
  final List<Product> products;
  final DateTime date;
  final double totalAmount;
  final double gst;
  final double totalTaxableAmount;

  Invoice({
    this.invoiceId,
    required this.recipient,
    required this.products,
    required this.date,
    required this.totalAmount,
    required this.gst,
    required this.totalTaxableAmount,
  });

  // Factory method to create an Invoice from a Map
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      invoiceId: map['invoice_id'] as int?,
      recipient: Recipient(
        id: map['recipient_id'] as int?, // Ensure recipient ID is stored
        name: map['recipient_name'] ?? 'Unknown',
        address: map['recipient_address'] ?? 'Unknown',
        gstin: map['recipient_gstin'] ?? 'Unknown',
        place: '',
      ),
      products: [], // Products will be fetched separately
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      gst: (map['gst'] as num?)?.toDouble() ?? 0.0,
      totalTaxableAmount:
          (map['total_taxable_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // **Add the copyWith method**
  Invoice copyWith({
    int? invoiceId,
    Recipient? recipient,
    List<Product>? products,
    DateTime? date,
    double? totalAmount,
    double? gst,
    double? totalTaxableAmount,
  }) {
    return Invoice(
      invoiceId: invoiceId ?? this.invoiceId,
      recipient: recipient ?? this.recipient,
      products: products ?? this.products,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      gst: gst ?? this.gst,
      totalTaxableAmount: totalTaxableAmount ?? this.totalTaxableAmount,
    );
  }
}
