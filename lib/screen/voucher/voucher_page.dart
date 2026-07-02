import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_maker/model/voucher.dart';
import 'package:invoice_maker/model/voucher_item.dart';
import 'package:invoice_maker/provider/settings_provider.dart';
import 'package:invoice_maker/provider/voucher_provider.dart';
import 'package:invoice_maker/screen/voucher/add_voucher_item_page.dart';
import 'package:invoice_maker/screen/voucher/voucher_item_tile.dart';
import 'package:invoice_maker/screen/widget/appbar.dart';
import 'package:invoice_maker/screen/widget/bottomnavbar.dart';
import 'package:invoice_maker/screen/widget/textfield.dart';
import 'package:provider/provider.dart';

class VoucherPage extends StatefulWidget {
  final Voucher? voucher;
  const VoucherPage({super.key, this.voucher});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  bool get _isEditMode => widget.voucher != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      nameController.text = widget.voucher!.name;
      gstinController.text = widget.voucher!.gstin;
      dateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.voucher!.date);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<VoucherProvider>(
          context,
          listen: false,
        ).loadVoucherForEditing(widget.voucher!);
      });
    } else {
      dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<VoucherProvider>(context, listen: false).clearItems();
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    gstinController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voucherProvider = Provider.of<VoucherProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: _isEditMode ? 'Edit Voucher' : 'New Voucher',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),

              const Text(
                'Name',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              CustomTextField(
                hintText: 'Enter Name',
                controller: nameController,
                validator: voucherProvider.validateField,
              ),
              const SizedBox(height: 16.0),

              const Text(
                'GSTIN',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              CustomTextField(
                hintText: 'Enter GSTIN',
                controller: gstinController,
              ),
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
                'Items',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),

              Consumer<VoucherProvider>(
                builder: (context, provider, child) {
                  final items = provider.addedItems;

                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No items added yet.',
                        style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...items.map(
                        (item) => VoucherItemTile(
                          item: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddVoucherItemPage(item: item),
                              ),
                            );
                          },
                          onDelete: () => provider.removeItem(item),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Issued Net Weight:',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${provider.totalIssuedNetWeight.toStringAsFixed(Provider.of<SettingsProvider>(context, listen: false).vchIssuedNetWtDp)} g',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddVoucherItemPage(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          isLoading: voucherProvider.isPDFLoading,
          label: _isEditMode ? 'Update Voucher' : 'Add Voucher',
          onTap: () async {
            try {
              final vp = Provider.of<VoucherProvider>(context, listen: false);

              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name.')),
                );
                return;
              }

              if (vp.addedItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No items added. Please add at least one item.',
                    ),
                  ),
                );
                return;
              }

              final date = DateFormat('yyyy-MM-dd').parse(dateController.text);
              final items = List<VoucherItem>.from(vp.addedItems);

              if (_isEditMode) {
                await vp.updateVoucher(
                  voucherId: widget.voucher!.voucherId!,
                  name: nameController.text,
                  gstin: gstinController.text,
                  date: date,
                  items: items,
                );
                final updated = widget.voucher!.copyWith(
                  name: nameController.text,
                  gstin: gstinController.text,
                  date: date,
                  items: items,
                  totalIssuedNetWeight: items.fold<double>(
                    0.0,
                    (s, i) => s + i.totalIssuedNetWeight,
                  ),
                );
                await vp.generateVoucherPDF(voucher: updated, context: context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voucher updated successfully!'),
                  ),
                );
                Navigator.pop(context);
              } else {
                final saved = await vp.addVoucher(
                  name: nameController.text,
                  gstin: gstinController.text,
                  date: date,
                  items: items,
                );
                await vp.generateVoucherPDF(voucher: saved, context: context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Voucher created and PDF generated successfully!',
                    ),
                  ),
                );
                nameController.clear();
                gstinController.clear();
                dateController.text = DateFormat(
                  'yyyy-MM-dd',
                ).format(DateTime.now());
              }
            } catch (e) {
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
