import 'package:flutter/material.dart';
import 'package:invoice_maker/model/product.dart';
import 'package:invoice_maker/utils/apptheme.dart'; // Import the colors

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete; // Callback for delete action

  const ProductTile({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.borderColor.withOpacity(0.5),
              blurRadius: 6.0,
              spreadRadius: 1.0,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Product Title with Delete Button**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete, // Call the delete callback
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // **HSN Code & Unit**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoText('HSN Code', product.hsnCode),
                _infoText('Unit', product.unitOfMeasure),
              ],
            ),
            const SizedBox(height: 10.0),

            // **Weight Information**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoText(
                  'Gross Wt',
                  '${product.grossWeight?.toStringAsFixed(2) ?? 'N/A'} g',
                ),
                if (product.stoneWeight != null && product.stoneWeight! > 0)
                  _infoText(
                    'Stone Wt',
                    '${product.stoneWeight?.toStringAsFixed(2) ?? 'N/A'} g',
                  ),
                _infoText(
                  'Net Wt',
                  '${product.netWeight?.toStringAsFixed(2) ?? 'N/A'} g',
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // **Pricing Information**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoText(
                  'Rate/Gram',
                  '₹${product.ratePerGram?.toStringAsFixed(2) ?? 'N/A'}',
                ),
                if (product.stoneCharge != null && product.stoneCharge! > 0)
                  _infoText(
                    'Stone Charge',
                    '₹${product.stoneCharge?.toStringAsFixed(2) ?? 'N/A'}',
                  ),
              ],
            ),
            const SizedBox(height: 12.0),

            // **Divider before Taxable Value**
            Divider(thickness: 1.0, color: AppColors.borderColor),
            const SizedBox(height: 10.0),

            // **Taxable Value**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Taxable Value:',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                ),
                Text(
                  '₹${product.taxableValue.toStringAsFixed(2)}',
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

  // Helper function to create text pairs
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
