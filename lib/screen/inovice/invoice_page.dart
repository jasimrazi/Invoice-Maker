import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_maker/model/invoice.dart';
import 'package:invoice_maker/model/product.dart';
import 'package:invoice_maker/provider/invoice_provider.dart';
import 'package:invoice_maker/provider/settings_provider.dart';
import 'package:invoice_maker/screen/add_product_page.dart';
import 'package:invoice_maker/screen/inovice/product_tile.dart';
import 'package:invoice_maker/screen/inovice/search_recepient.dart';
import 'package:invoice_maker/screen/widget/appbar.dart';
import 'package:invoice_maker/screen/widget/bottomnavbar.dart';
import 'package:invoice_maker/screen/widget/textfield.dart';
import 'package:provider/provider.dart';

class InvoicePage extends StatefulWidget {
  final Invoice? invoice;
  const InvoicePage({super.key, this.invoice});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  bool get _isEditMode => widget.invoice != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      dateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.invoice!.date);
      gstController.text = widget.invoice!.gst.toStringAsFixed(2);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<InvoiceProvider>(
          context,
          listen: false,
        ).loadInvoiceForEditing(widget.invoice!);
      });
    } else {
      dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      gstController.text = '2.50';
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: _isEditMode ? 'Edit Invoice' : 'Invoice Page',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              const Text(
                'Recipient',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              SearchRecipient(skipInitialClear: _isEditMode),
              const SizedBox(height: 16.0),
              const Text(
                'Date',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: 'Enter Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(selectedDate);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'GST (%)',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              CustomTextField(
                hintText: 'Enter GST',
                controller: gstController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Items',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Consumer<InvoiceProvider>(
                builder: (context, provider, child) {
                  final products = provider.addedProducts;

                  if (products.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products added yet.',
                        style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      ),
                    );
                  }

                  final gstPercentage =
                      double.tryParse(gstController.text) ?? 2.50;
                  final totalBeforeTax =
                      provider.calculateTotalAmountBeforeTax();
                  final cgst = provider.calculateTax(gstPercentage);
                  final sgst = provider.calculateTax(gstPercentage);
                  final totalTax = provider.calculateTotalTax(gstPercentage);
                  final totalAfterTax = provider.calculateTotalAmountAfterTax(
                    gstPercentage,
                  );
                  final dp =
                      Provider.of<SettingsProvider>(
                        context,
                        listen: false,
                      ).invAmountsDp;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...products.map((product) {
                        return ProductTile(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AddProductPage(product: product),
                              ),
                            );
                          },
                          onDelete: () {
                            provider.removeProduct(product);
                          },
                        );
                      }).toList(),
                      const SizedBox(height: 16.0),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _summaryRow(
                              'Total Before Tax:',
                              '₹${totalBeforeTax.toStringAsFixed(dp)}',
                            ),
                            _summaryRow(
                              'CGST (${gstPercentage.toStringAsFixed(dp)}%):',
                              '₹${cgst.toStringAsFixed(dp)}',
                            ),
                            _summaryRow(
                              'SGST (${gstPercentage.toStringAsFixed(dp)}%):',
                              '₹${sgst.toStringAsFixed(dp)}',
                            ),
                            _summaryRow(
                              'Total Tax:',
                              '₹${totalTax.toStringAsFixed(dp)}',
                            ),
                            const Divider(thickness: 1.0),
                            _summaryRow(
                              'Total After Tax:',
                              '₹${totalAfterTax.toStringAsFixed(dp)}',
                              isBold: true,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
        floatingActionButton:
            invoiceProvider.selectedRecipient != null
                ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProductPage(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
                : const SizedBox(),
        bottomNavigationBar: CustomBottomNavBar(
          isLoading: invoiceProvider.isPDFloading,
          label: _isEditMode ? "Update Invoice" : "Make Invoice",
          onTap: () async {
            try {
              final invoiceProvider = Provider.of<InvoiceProvider>(
                context,
                listen: false,
              );

              if (invoiceProvider.addedProducts.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No products added. Please add at least one product.',
                    ),
                  ),
                );
                return;
              }

              final date = DateFormat('yyyy-MM-dd').parse(dateController.text);
              final recipient = invoiceProvider.selectedRecipient!;

              final products = List<Product>.from(
                invoiceProvider.addedProducts,
              );

              final totalAmount = invoiceProvider.calculateTotalAmountAfterTax(
                double.tryParse(gstController.text) ?? 2.50,
              );
              final gst = double.tryParse(gstController.text) ?? 2.50;
              final totalTaxableAmount =
                  invoiceProvider.calculateTotalAmountBeforeTax();

              if (_isEditMode) {
                await invoiceProvider.updateInvoice(
                  invoiceId: widget.invoice!.invoiceId!,
                  date: date,
                  recipient: recipient,
                  products: products,
                  totalAmount: totalAmount,
                  gst: gst,
                  totalTaxableAmount: totalTaxableAmount,
                );

                final updatedInvoice = widget.invoice!.copyWith(
                  date: date,
                  recipient: recipient,
                  products: products,
                  totalAmount: totalAmount,
                  gst: gst,
                  totalTaxableAmount: totalTaxableAmount,
                );

                await invoiceProvider.generateInvoicePDF(
                  invoice: updatedInvoice,
                  context: context,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invoice updated successfully!'),
                  ),
                );

                Navigator.pop(context);
              } else {
                print("Products before creating invoice: $products");

                final invoice = Invoice(
                  invoiceId: 0,
                  recipient: recipient,
                  products: products,
                  date: date,
                  totalAmount: totalAmount,
                  gst: gst,
                  totalTaxableAmount: totalTaxableAmount,
                );

                print("Invoice created: ${invoice.products}");

                final updatedInvoice = await invoiceProvider.addInvoice(
                  date: date,
                  recipient: recipient,
                  products: products,
                  totalAmount: totalAmount,
                  gst: gst,
                  totalTaxableAmount: totalTaxableAmount,
                );

                print("Products after addInvoice: ${updatedInvoice.products}");

                print("Before PDF Generation: ${updatedInvoice.products}");
                await invoiceProvider.generateInvoicePDF(
                  invoice: updatedInvoice,
                  context: context,
                );
                print("After PDF Generation: ${updatedInvoice.products}");

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Invoice created and PDF generated successfully!',
                    ),
                  ),
                );

                print(
                  "Before Clearing Product List: ${invoiceProvider.addedProducts}",
                );

                invoiceProvider.clearProductList();
                invoiceProvider.selectedRecipient = null;
                dateController.text = DateFormat(
                  'yyyy-MM-dd',
                ).format(DateTime.now());
                gstController.text = '2.50';

                print(
                  "After Clearing Product List: ${invoiceProvider.addedProducts}",
                );
              }
            } catch (e) {
              print("Exception: ${e.toString()}");
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
            }
          },
        ),
      ),
    );
  }
}

Widget _summaryRow(
  String label,
  String value, {
  bool isBold = false,
  Color? color,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    ),
  );
}
