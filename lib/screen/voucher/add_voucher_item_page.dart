import 'package:flutter/material.dart';
import 'package:invoice_maker/model/voucher_item.dart';
import 'package:invoice_maker/provider/voucher_provider.dart';
import 'package:invoice_maker/screen/widget/appbar.dart';
import 'package:invoice_maker/screen/widget/bottomnavbar.dart';
import 'package:invoice_maker/screen/widget/textfield.dart';
import 'package:provider/provider.dart';

class AddVoucherItemPage extends StatefulWidget {
  final VoucherItem? item;
  const AddVoucherItemPage({super.key, this.item});

  @override
  State<AddVoucherItemPage> createState() => _AddVoucherItemPageState();
}

class _AddVoucherItemPageState extends State<AddVoucherItemPage> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController hsnCodeController = TextEditingController();
  final TextEditingController issuedGrossWeightController =
      TextEditingController();
  final TextEditingController touchController = TextEditingController();
  final TextEditingController issuedNetWeightController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final i = widget.item!;
      itemNameController.text = i.itemName;
      hsnCodeController.text = i.hsnCode;
      issuedGrossWeightController.text = i.issuedGrossWeight.toString();
      touchController.text = i.touch.toString();
      issuedNetWeightController.text = i.issuedNetWeight.toString();
    }
  }

  @override
  void dispose() {
    itemNameController.dispose();
    hsnCodeController.dispose();
    issuedGrossWeightController.dispose();
    touchController.dispose();
    issuedNetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voucherProvider = Provider.of<VoucherProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: _isEditMode ? 'Edit Item' : 'Add Item'),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  const Text(
                    'Item Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Item Name',
                    controller: itemNameController,
                    validator: voucherProvider.validateField,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'HSN Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'HSN Code',
                    controller: hsnCodeController,
                    validator: voucherProvider.validateField,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Issued Gross Weight',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Issued Gross Weight',
                    controller: issuedGrossWeightController,
                    validator: voucherProvider.validateField,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Touch',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Touch',
                    controller: touchController,
                    validator: voucherProvider.validateField,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Issued Net Weight',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Issued Net Weight',
                    controller: issuedNetWeightController,
                    validator: voucherProvider.validateField,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          label: _isEditMode ? 'Update Item' : 'Add Item',
          onTap: () {
            if (_formKey.currentState!.validate()) {
              final vp = Provider.of<VoucherProvider>(context, listen: false);
              final itemName = itemNameController.text;
              final hsnCode = hsnCodeController.text;
              final issuedGrossWeight = double.parse(
                issuedGrossWeightController.text,
              );
              final touch = double.parse(touchController.text);
              final issuedNetWeight = double.parse(
                issuedNetWeightController.text,
              );

              if (_isEditMode) {
                vp.replaceItem(
                  widget.item!,
                  itemName: itemName,
                  hsnCode: hsnCode,
                  issuedGrossWeight: issuedGrossWeight,
                  touch: touch,
                  issuedNetWeight: issuedNetWeight,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item updated successfully!')),
                );
                Navigator.pop(context);
              } else {
                vp.addItem(
                  itemName: itemName,
                  hsnCode: hsnCode,
                  issuedGrossWeight: issuedGrossWeight,
                  touch: touch,
                  issuedNetWeight: issuedNetWeight,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item added successfully!')),
                );
                issuedGrossWeightController.clear();
                touchController.clear();
                issuedNetWeightController.clear();
              }
            }
          },
        ),
      ),
    );
  }
}
