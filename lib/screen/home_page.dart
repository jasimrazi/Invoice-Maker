import 'package:double_tap_to_exit/double_tap_to_exit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_maker/provider/invoice_provider.dart';
import 'package:invoice_maker/provider/settings_provider.dart';
import 'package:invoice_maker/provider/voucher_provider.dart';
import 'package:invoice_maker/screen/inovice/invoice_page.dart';
import 'package:invoice_maker/screen/settings_page.dart';
import 'package:invoice_maker/screen/voucher/voucher_page.dart';
import 'package:invoice_maker/screen/widget/bottomnavbar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
      Provider.of<VoucherProvider>(context, listen: false).fetchVouchers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DoubleTapToExit(
      snackBar: const SnackBar(content: Text("Tap again to exit!")),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [Tab(text: 'Invoices'), Tab(text: 'Vouchers')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Invoices Tab ────────────────────────────────────────
            Consumer2<InvoiceProvider, SettingsProvider>(
              builder: (context, invoiceProvider, settings, child) {
                if (invoiceProvider.recentInvoices.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No invoices found.',
                          style: TextStyle(fontSize: 16.0, color: Colors.grey),
                        ),
                        Text(
                          'Pull to refresh.',
                          style: TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final invoices =
                    invoiceProvider.recentInvoices.reversed.toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<InvoiceProvider>(
                      context,
                      listen: false,
                    ).fetchInvoices();
                  },
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invoice #${settings.formatInvoiceNumber(invoice.invoiceId!, invoice.date)}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text('Recipient: ${invoice.recipient.name}'),
                              Text(
                                'Date: ${DateFormat('MMMM d y').format(invoice.date)}',
                              ),
                              Text(
                                'Total Amount: ₹${invoice.totalAmount.toStringAsFixed(settings.invAmountsDp)}',
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed:
                                        invoiceProvider.isPDFloading
                                            ? null
                                            : () async {
                                              try {
                                                await Provider.of<
                                                  InvoiceProvider
                                                >(
                                                  context,
                                                  listen: false,
                                                ).generateInvoicePDF(
                                                  invoice: invoice,
                                                  context: context,
                                                  isShare: false,
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error: ${e.toString()}',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                    icon:
                                        invoiceProvider.isPDFloading
                                            ? const CupertinoActivityIndicator()
                                            : const Icon(Icons.print),
                                    label: const Text("Print"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  InvoicePage(invoice: invoice),
                                        ),
                                      ).then((_) {
                                        Provider.of<InvoiceProvider>(
                                          context,
                                          listen: false,
                                        ).fetchInvoices();
                                      });
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text("Edit"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        await Provider.of<InvoiceProvider>(
                                          context,
                                          listen: false,
                                        ).generateInvoicePDF(
                                          invoice: invoice,
                                          context: context,
                                          isShare: true,
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.share),
                                    label: const Text("Share"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // ── Vouchers Tab ────────────────────────────────────────
            Consumer2<VoucherProvider, SettingsProvider>(
              builder: (context, voucherProvider, settings, child) {
                if (voucherProvider.recentVouchers.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No vouchers found.',
                          style: TextStyle(fontSize: 16.0, color: Colors.grey),
                        ),
                        Text(
                          'Pull to refresh.',
                          style: TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final vouchers =
                    voucherProvider.recentVouchers.reversed.toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<VoucherProvider>(
                      context,
                      listen: false,
                    ).fetchVouchers();
                  },
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: vouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = vouchers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Voucher #${voucher.voucherId}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text('Name: ${voucher.name}'),
                              Text(
                                'Date: ${DateFormat('MMMM d y').format(voucher.date)}',
                              ),
                              Text(
                                'Total Issued Net Wt: ${voucher.totalIssuedNetWeight.toStringAsFixed(settings.vchIssuedNetWtDp)} g',
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed:
                                        voucherProvider.isPDFLoading
                                            ? null
                                            : () async {
                                              try {
                                                await Provider.of<
                                                  VoucherProvider
                                                >(
                                                  context,
                                                  listen: false,
                                                ).generateVoucherPDF(
                                                  voucher: voucher,
                                                  context: context,
                                                  isShare: false,
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error: ${e.toString()}',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                    icon:
                                        voucherProvider.isPDFLoading
                                            ? const CupertinoActivityIndicator()
                                            : const Icon(Icons.print),
                                    label: const Text("Print"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  VoucherPage(voucher: voucher),
                                        ),
                                      ).then((_) {
                                        Provider.of<VoucherProvider>(
                                          context,
                                          listen: false,
                                        ).fetchVouchers();
                                      });
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text("Edit"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        await Provider.of<VoucherProvider>(
                                          context,
                                          listen: false,
                                        ).generateVoucherPDF(
                                          voucher: voucher,
                                          context: context,
                                          isShare: true,
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.share),
                                    label: const Text("Share"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: AnimatedBuilder(
          animation: _tabController,
          builder:
              (context, _) => CustomBottomNavBar(
                label:
                    _tabController.index == 0 ? 'Add Invoice' : 'Add Voucher',
                onTap: () {
                  if (_tabController.index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InvoicePage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VoucherPage(),
                      ),
                    );
                  }
                },
              ),
        ),
      ),
    );
  }
}
