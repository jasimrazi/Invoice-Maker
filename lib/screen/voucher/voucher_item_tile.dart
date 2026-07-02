import 'package:flutter/material.dart';
import 'package:invoice_maker/model/voucher_item.dart';
import 'package:invoice_maker/provider/settings_provider.dart';
import 'package:invoice_maker/utils/apptheme.dart';
import 'package:provider/provider.dart';

class VoucherItemTile extends StatelessWidget {
  final VoucherItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const VoucherItemTile({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final issuedGrossWtDp = settings.vchIssuedGrossWtDp;
    final touchDp = settings.vchTouchDp;
    final issuedNetWtDp = settings.vchIssuedNetWtDp;
    final hasCopper =
        item.copperGrossWeight != null || item.copperNetWeight != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.borderColor.withValues(alpha: 0.5),
              blurRadius: 6.0,
              spreadRadius: 1.0,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // HSN Code + Touch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoText('HSN Code', item.hsnCode),
                _infoText('Touch', item.touch.toStringAsFixed(touchDp)),
              ],
            ),
            const SizedBox(height: 10.0),

            // Issued Gross Wt + Issued Net Wt
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoText(
                  'Issued Gross Wt',
                  '${item.issuedGrossWeight.toStringAsFixed(issuedGrossWtDp)} g',
                ),
                _infoText(
                  'Issued Net Wt',
                  '${item.issuedNetWeight.toStringAsFixed(issuedNetWtDp)} g',
                ),
              ],
            ),
            if (hasCopper) ...[
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoText('Copper', ''),
                  _infoText(
                    'Gross Wt',
                    item.copperGrossWeight == null
                        ? '-'
                        : '${item.copperGrossWeight!.toStringAsFixed(issuedGrossWtDp)} g',
                  ),
                  _infoText(
                    'Net Wt',
                    item.copperNetWeight == null
                        ? '-'
                        : '${item.copperNetWeight!.toStringAsFixed(issuedNetWtDp)} g',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12.0),
            Divider(thickness: 1.0, color: AppColors.borderColor),
            const SizedBox(height: 8.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Issued Net Weight:',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                ),
                Text(
                  '${item.totalIssuedNetWeight.toStringAsFixed(issuedNetWtDp)} g',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12.0, color: AppColors.borderColor),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }
}
