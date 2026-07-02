import 'package:flutter/material.dart';
import 'package:invoice_maker/model/product.dart';
import 'package:invoice_maker/provider/invoice_provider.dart';
import 'package:invoice_maker/screen/widget/appbar.dart';
import 'package:invoice_maker/screen/widget/bottomnavbar.dart';
import 'package:invoice_maker/screen/widget/textfield.dart';
import 'package:invoice_maker/utils/default_values.dart';
import 'package:provider/provider.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // Controllers for the text fields
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hsnCodeController = TextEditingController();
  final TextEditingController unitOfMeasureController = TextEditingController();
  final TextEditingController grossWeightController = TextEditingController();
  final TextEditingController stoneWeightController = TextEditingController();
  final TextEditingController netWeightController = TextEditingController();
  final TextEditingController ratePerGramController = TextEditingController();
  final TextEditingController stoneChargeController = TextEditingController();
  final TextEditingController taxableValueController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final p = widget.product!;
      descriptionController.text = p.description;
      hsnCodeController.text = p.hsnCode;
      unitOfMeasureController.text = p.unitOfMeasure;
      grossWeightController.text = p.grossWeight.toString();
      stoneWeightController.text =
          (p.stoneWeight != null && p.stoneWeight! > 0)
              ? p.stoneWeight.toString()
              : '';
      ratePerGramController.text = p.ratePerGram.toString();
      stoneChargeController.text =
          (p.stoneCharge != null && p.stoneCharge! > 0)
              ? p.stoneCharge.toString()
              : '';
    } else {
      descriptionController.text = DefaultValues.descriptionOfGoods;
      hsnCodeController.text = DefaultValues.hsnCode;
      unitOfMeasureController.text = DefaultValues.unitOfMeasure;
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers to avoid memory leaks
    descriptionController.dispose();
    hsnCodeController.dispose();
    unitOfMeasureController.dispose();
    grossWeightController.dispose();
    stoneWeightController.dispose();
    netWeightController.dispose();
    ratePerGramController.dispose();
    stoneChargeController.dispose();
    taxableValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: _isEditMode ? 'Edit Product' : 'Add Product',
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Description of Goods
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description of Goods',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: 'Description of Goods',
                        controller: descriptionController,
                        validator: invoiceProvider.validateField,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // HSN Code
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HSN Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: 'HSN Code',
                        controller: hsnCodeController,
                        validator: invoiceProvider.validateField,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Unit of Measure
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unit of Measure',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: 'Unit of Measure',
                        controller: unitOfMeasureController,
                        validator: invoiceProvider.validateField,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quantity Section
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'Gross Weight',
                          controller: grossWeightController,
                          validator: invoiceProvider.validateField,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'Stone Weight',
                          controller: stoneWeightController,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              return double.tryParse(value) == null
                                  ? 'Stone Weight must be a valid number'
                                  : null;
                            }
                            return null; // Allow empty value
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rate Per Gram
                  CustomTextField(
                    hintText: 'Rate Per Gram',
                    controller: ratePerGramController,
                    validator: invoiceProvider.validateField,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Stone Charge
                  CustomTextField(
                    hintText: 'Stone Charge',
                    controller: stoneChargeController,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        return double.tryParse(value) == null
                            ? 'Stone Charge must be a valid number'
                            : null;
                      }
                      return null; // Allow empty value
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          label: _isEditMode ? "Update Product" : "Add Product",
          onTap: () {
            if (_formKey.currentState!.validate()) {
              final invoiceProvider = Provider.of<InvoiceProvider>(
                context,
                listen: false,
              );

              if (_isEditMode) {
                invoiceProvider.replaceProduct(
                  widget.product!,
                  description: descriptionController.text,
                  hsnCode: hsnCodeController.text,
                  unitOfMeasure: unitOfMeasureController.text,
                  grossWeight: double.parse(grossWeightController.text),
                  stoneWeight:
                      stoneWeightController.text.isNotEmpty
                          ? double.parse(stoneWeightController.text)
                          : null,
                  ratePerGram: double.parse(ratePerGramController.text),
                  stoneCharge:
                      stoneChargeController.text.isNotEmpty
                          ? double.parse(stoneChargeController.text)
                          : null,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product updated successfully!'),
                  ),
                );
                Navigator.pop(context);
              } else {
                invoiceProvider.addProduct(
                  description: descriptionController.text,
                  hsnCode: hsnCodeController.text,
                  unitOfMeasure: unitOfMeasureController.text,
                  grossWeight: double.parse(grossWeightController.text),
                  stoneWeight:
                      stoneWeightController.text.isNotEmpty
                          ? double.parse(stoneWeightController.text)
                          : null,
                  ratePerGram: double.parse(ratePerGramController.text),
                  stoneCharge:
                      stoneChargeController.text.isNotEmpty
                          ? double.parse(stoneChargeController.text)
                          : null,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added successfully!')),
                );

                grossWeightController.clear();
                stoneWeightController.clear();
                netWeightController.clear();
                ratePerGramController.clear();
                stoneChargeController.clear();
                taxableValueController.clear();
              }
            }
          },
        ),
      ),
    );
  }
}
