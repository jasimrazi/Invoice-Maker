import 'package:double_tap_to_exit/double_tap_to_exit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_maker/database/database_debugger.dart';
import 'package:invoice_maker/provider/invoice_provider.dart';
import 'package:invoice_maker/screen/inovice/invoice_page.dart';
import 'package:invoice_maker/screen/widget/appbar.dart';
import 'package:invoice_maker/screen/widget/bottomnavbar.dart';
import 'package:invoice_maker/utils/apptheme.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DoubleTapToExit(
      snackBar: const SnackBar(content: Text("Tap again to exit!")),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Home Page'),
        body: Consumer<InvoiceProvider>(
          builder: (context, invoiceProvider, child) {
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

            // Reverse the list so the latest invoice appears at the top
            final invoices = invoiceProvider.recentInvoices.reversed.toList();

            return RefreshIndicator(
              onRefresh: () async {
                await Provider.of<InvoiceProvider>(
                  context,
                  listen: false,
                ).fetchInvoices();
              },
              // AlwaysScrollableScrollPhysics forces the refresh even if the list is short
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
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
                            'Invoice #${invoice.invoiceId}',
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
                            'Total Amount: ₹${invoice.totalAmount.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Print Button with accurate loading state
                              ElevatedButton.icon(
                                onPressed:
                                    invoiceProvider.isPDFloading
                                        ? null // disable the button when loading
                                        : () async {
                                          try {
                                            await Provider.of<InvoiceProvider>(
                                              context,
                                              listen: false,
                                            ).generateInvoicePDF(
                                              invoice: invoice,
                                              context: context,
                                              isShare:
                                                  false, // Open for printing
                                            );
                                          } catch (e) {
                                            print('Error printing invoice: $e');
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

                              // Share Button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await Provider.of<InvoiceProvider>(
                                      context,
                                      listen: false,
                                    ).generateInvoicePDF(
                                      invoice: invoice,
                                      context: context,
                                      isShare: true, // Share the PDF
                                    );
                                  } catch (e) {
                                    print('Error sharing invoice: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
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
        bottomNavigationBar: CustomBottomNavBar(
          label: 'Add',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InvoicePage()),
              ),
        ),
      ),
    );
  }
}
