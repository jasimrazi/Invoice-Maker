import 'package:flutter/material.dart';
import 'package:invoice_maker/provider/settings_provider.dart';
import 'package:invoice_maker/screen/widget/appbar.dart';
import 'package:invoice_maker/utils/apptheme.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 1.0,
            child: ListTile(
              title: const Text(
                'Decimal',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Decimal places for invoices and vouchers'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DecimalSettingsPage(),
                  ),
                );
              },
            ),
          ),
          Card(
            elevation: 1.0,
            child: ListTile(
              title: const Text(
                'Invoice Numbering',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Choose invoice number format'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoiceNumberingSettingsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceNumberingSettingsPage extends StatelessWidget {
  const InvoiceNumberingSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Invoice Numbering'),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Format',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      DropdownButtonFormField<String>(
                        initialValue: settings.invNumberFormat,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: SettingsProvider.invoiceNumberNumeric,
                            child: Text('Number only (1, 2, 3)'),
                          ),
                          DropdownMenuItem(
                            value: SettingsProvider.invoiceNumberYearlyLetter,
                            child: Text(
                              'Yearly letter (${settings.formatInvoiceNumber(1, DateTime.now())})',
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) settings.setInvNumberFormat(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (settings.invNumberFormat ==
                  SettingsProvider.invoiceNumberYearlyLetter) ...[
                const SizedBox(height: 16.0),
                const _SectionHeader(title: 'Yearly Letter Starts From'),
                _NumberDropdownTile(
                  label: 'Start Month',
                  value: settings.invNumberStartMonth,
                  values: List.generate(12, (i) => i + 1),
                  labelFor: _monthName,
                  onChanged: settings.setInvNumberStartMonth,
                ),
                _NumberDropdownTile(
                  label: 'Start Year',
                  value: settings.invNumberStartYear,
                  values: List.generate(21, (i) => 2020 + i),
                  labelFor: (value) => value.toString(),
                  onChanged: settings.setInvNumberStartYear,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class DecimalSettingsPage extends StatelessWidget {
  const DecimalSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Decimal Settings'),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const _SectionHeader(title: 'Invoice - Weights'),
              _DecimalTile(
                label: 'Gross Weight',
                value: settings.invGrossWtDp,
                onChanged: settings.setInvGrossWtDp,
              ),
              _DecimalTile(
                label: 'Stone Weight',
                value: settings.invStoneWtDp,
                onChanged: settings.setInvStoneWtDp,
              ),
              _DecimalTile(
                label: 'Net Weight',
                value: settings.invNetWtDp,
                onChanged: settings.setInvNetWtDp,
              ),
              const SizedBox(height: 16.0),
              const _SectionHeader(title: 'Invoice - Pricing'),
              _DecimalTile(
                label: 'Rate / Gram',
                value: settings.invRateDp,
                onChanged: settings.setInvRateDp,
              ),
              _DecimalTile(
                label: 'Stone Charge',
                value: settings.invStoneChargeDp,
                onChanged: settings.setInvStoneChargeDp,
              ),
              _DecimalTile(
                label: 'Taxable Value',
                value: settings.invTaxableDp,
                onChanged: settings.setInvTaxableDp,
              ),
              _DecimalTile(
                label: 'Tax & Total Amounts',
                value: settings.invAmountsDp,
                onChanged: settings.setInvAmountsDp,
              ),
              const SizedBox(height: 16.0),
              const _SectionHeader(title: 'Voucher'),
              _DecimalTile(
                label: 'Issued Gross Weight',
                value: settings.vchIssuedGrossWtDp,
                onChanged: settings.setVchIssuedGrossWtDp,
              ),
              _DecimalTile(
                label: 'Touch',
                value: settings.vchTouchDp,
                onChanged: settings.setVchTouchDp,
              ),
              _DecimalTile(
                label: 'Issued Net Weight',
                value: settings.vchIssuedNetWtDp,
                onChanged: settings.setVchIssuedNetWtDp,
              ),
              const SizedBox(height: 24.0),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DecimalTile extends StatelessWidget {
  final String label;
  final int value;
  final Future<void> Function(int) onChanged;

  const _DecimalTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '1234.${List.filled(value, '5').join()}',
              style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
            ),
            const SizedBox(width: 12.0),
            DropdownButton<int>(
              value: value,
              underline: const SizedBox(),
              items: List.generate(
                7,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    '$i',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberDropdownTile extends StatelessWidget {
  final String label;
  final int value;
  final List<int> values;
  final String Function(int) labelFor;
  final Future<void> Function(int) onChanged;

  const _NumberDropdownTile({
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            DropdownButton<int>(
              value: value,
              underline: const SizedBox(),
              items:
                  values
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            labelFor(v),
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}
