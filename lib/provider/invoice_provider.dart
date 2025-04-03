import 'dart:io';

import 'package:flutter/material.dart';
import 'package:invoice_maker/database/invoice_db.dart';
import 'package:invoice_maker/database/product_db.dart';
import 'package:invoice_maker/database/recepient_db.dart';
import 'package:invoice_maker/model/invoice.dart';
import 'package:invoice_maker/model/product.dart';
import 'package:invoice_maker/model/recipient.dart';
import 'package:invoice_maker/provider/invoice_generator.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceDB _invoiceDB = InvoiceDB();
  final InvoiceGenerator _invoiceGenerator = InvoiceGenerator();
  final ProductDB _productDB = ProductDB(); // Define _productDB
  final RecipientDB _recipientDB = RecipientDB(); // Define _productDB

  Recipient? selectedRecipient; // Nullable to handle no selection
  List<Recipient> suggestions = []; // Store suggestions as Recipient objects
  bool hasStartedTyping = false; // Track if the user has started typing
  List<Product> addedProducts = []; // Temporary list for added products
  List<Invoice> recentInvoices = [];

  bool isPDFloading = false;

  void updateSuggestions(List<Recipient> newSuggestions) {
    suggestions = newSuggestions;
    print('Updated suggestions: $suggestions'); // Debug log
    notifyListeners();
  }

  void selectRecipient(Recipient recipient) {
    selectedRecipient = recipient;
    suggestions = []; // Clear suggestions after selection
    hasStartedTyping = false; // Reset typing state after selection
    notifyListeners();
  }

  void clearSuggestions() {
    suggestions = [];
    notifyListeners();
  }

  void clearSearchField() {
    selectedRecipient = null;
    hasStartedTyping = false;
    notifyListeners();
  }

  void setTypingState(bool isTyping) {
    hasStartedTyping = isTyping;
    notifyListeners();
  }

  String? validateField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  // Add a product to the list (temporarily before invoice creation)
  void addProduct({
    required String description,
    required String hsnCode,
    required String unitOfMeasure,
    required double grossWeight,
    double? stoneWeight, // Nullable
    required double ratePerGram,
    double? stoneCharge, // Nullable
  }) async {
    double netWeight = grossWeight - (stoneWeight ?? 0);
    double taxableValue = (netWeight * ratePerGram) + (stoneCharge ?? 0);

    final product = Product(
      description: description,
      hsnCode: hsnCode,
      unitOfMeasure: unitOfMeasure,
      grossWeight: grossWeight,
      stoneWeight: stoneWeight ?? 0.0, // Default to 0.0 if null
      netWeight: netWeight,
      ratePerGram: ratePerGram,
      stoneCharge: stoneCharge ?? 0.0, // Default to 0.0 if null
      taxableValue: taxableValue,
      invoiceId: -1, // Temporary ID (not linked to an invoice yet)
    );

    // Add the product to the list temporarily
    addedProducts.add(product); // Add to the temporary list
    notifyListeners(); // Notify listeners to update the UI
    print('Product added temporarily: $product'); // Debug log
  }

  void removeProduct(Product product) async {
    try {
      // Remove the product from the list
      addedProducts.remove(product);
      notifyListeners(); // Notify listeners to update the UI
      print('Product removed: ${product.description}');
    } catch (e) {
      print('Error removing product: $e');
    }
  }

  void clearProductList() {
    addedProducts.clear(); // Clear the temporary list
    notifyListeners(); // Notify listeners to update the UI
    print('Product list cleared.'); // Debug log
  }

  double calculateTotalAmountBeforeTax() {
    return addedProducts.fold(
      0.0,
      (sum, product) => sum + product.taxableValue,
    );
  }

  // Calculate CGST and SGST based on the GST percentage
  double calculateTax(double gstPercentage) {
    final totalBeforeTax = calculateTotalAmountBeforeTax();
    return (totalBeforeTax * gstPercentage) / 100;
  }

  // Calculate the total tax (CGST + SGST)
  double calculateTotalTax(double gstPercentage) {
    return calculateTax(gstPercentage) * 2; // CGST + SGST
  }

  // Calculate the total amount after tax
  double calculateTotalAmountAfterTax(double gstPercentage) {
    final totalBeforeTax = calculateTotalAmountBeforeTax();
    final totalTax = calculateTotalTax(gstPercentage);
    return totalBeforeTax + totalTax;
  }

  Future<Invoice> addInvoice({
    required DateTime date,
    required Recipient recipient,
    required double totalAmount,
    required double gst,
    required double totalTaxableAmount,
    required List<Product> products,
  }) async {
    try {
      // Insert the recipient if not already in the database
      final int recipientId =
          recipient.id ?? await _recipientDB.insertRecipient(recipient);

      // Create the invoice object
      final invoice = Invoice(
        recipient: recipient.copyWith(id: recipientId),
        products: products, // Use the passed products list
        date: date,
        totalAmount: totalAmount,
        gst: gst,
        totalTaxableAmount: totalTaxableAmount,
      );

      // Insert the invoice into the database
      final int invoiceId = await _invoiceDB.insertInvoice(
        invoice,
        recipientId,
      );

      // Insert all associated products into the database
      for (final product in products) {
        await _productDB.insertProduct(
          product.copyWith(invoiceId: invoiceId),
          invoiceId,
        );
      }

      // Create an updated invoice with the correct invoiceId
      final updatedInvoice = Invoice(
        invoiceId: invoiceId,
        recipient: invoice.recipient,
        products: invoice.products,
        date: invoice.date,
        totalAmount: invoice.totalAmount,
        gst: invoice.gst,
        totalTaxableAmount: invoice.totalTaxableAmount,
      );

      // Clear the temporary list after invoice creation
      addedProducts.clear();
      notifyListeners();

      print('Invoice and associated products added successfully.');
      return updatedInvoice; // Return the updated invoice
    } catch (e) {
      print('Error adding invoice: $e');
      throw Exception('Failed to add invoice: $e');
    }
  }

  Future<void> fetchInvoices() async {
    try {
      List<Invoice> invoices = await _invoiceDB.getInvoices();

      for (int i = 0; i < invoices.length; i++) {
        final recipient = await _recipientDB.getRecipientById(
          invoices[i].recipient.id!,
        );
        if (recipient != null) {
          invoices[i] = invoices[i].copyWith(recipient: recipient);
        }
      }

      recentInvoices = invoices;
      notifyListeners();
    } catch (e) {
      print('Error fetching invoices: $e');
      recentInvoices = [];
      notifyListeners();
    }
  }



  Future<void> generateInvoicePDF({
    required Invoice invoice,
    required BuildContext context,
    bool isShare = false,
  }) async {
    isPDFloading = true;
    try {
      // Fetch products associated with the invoice
      final List<Product> products = await _productDB.getProductsByInvoiceId(
        invoice.invoiceId!,
      );

      // Convert products to a list of maps for the PDF generator
      final List<Map<String, dynamic>> productList =
          products.map((product) {
            return {
              "description": product.description,
              "hsn_code": product.hsnCode,
              "unit_of_measure": product.unitOfMeasure,
              "gross_weight": product.grossWeight,
              "stone_weight": product.stoneWeight,
              "net_weight": product.netWeight,
              "rate_per_gram": product.ratePerGram,
              "stone_charge": product.stoneCharge,
              "taxable_value": product.taxableValue,
            };
          }).toList();

      // Use the InvoiceGenerator to create the PDF
      await _invoiceGenerator.createInvoice(
        invoiceId: invoice.invoiceId.toString(),
        recipientName: invoice.recipient.name,
        recipientAddress: invoice.recipient.address,
        recipientPlace: invoice.recipient.place,
        gstin: invoice.recipient.gstin,
        products: productList,
        cgstPercentage: invoice.gst,
        sgstPercentage: invoice.gst,
        context: context,
        isShare: isShare,
      );

      // Move the success message here
      print('PDF generated successfully for Invoice #${invoice.invoiceId}');
    } catch (e) {
      print('Error generating PDF: $e');
      throw Exception('Failed to generate PDF: $e');
    } finally {
      isPDFloading = false;
    }
  }
}
