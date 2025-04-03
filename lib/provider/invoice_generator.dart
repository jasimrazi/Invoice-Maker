import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_maker/utils/amount_in_words.dart';
import 'package:invoice_maker/utils/default_values.dart';
import 'package:invoice_maker/utils/truncate_with_ellpises.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceGenerator {
  // Helper function to truncate text with ellipsis based on column width

  Future<void> createInvoice({
    required String invoiceId,
    required String recipientName,
    required String recipientAddress,
    required String recipientPlace,
    required String gstin,
    required List<Map<String, dynamic>> products,
    required double cgstPercentage,
    required double sgstPercentage,
    required BuildContext context,
    bool isShare = false,
  }) async {
    try {
      final ByteData fontData = await rootBundle.load(
        "assets/fonts/NotoSans-Regular.ttf",
      );
      final Uint8List fontBytes = fontData.buffer.asUint8List();

      final PdfFont notoSansFont = PdfTrueTypeFont(fontBytes, 12);
      final PdfFont notoSansBold = PdfTrueTypeFont(
        fontBytes,
        18,
        style: PdfFontStyle.bold,
      );
      final PdfFont notoSansSmall = PdfTrueTypeFont(fontBytes, 10);

      final PdfDocument document = PdfDocument();
      PdfPage page = document.pages.add();
      final Size pageSize = page.getClientSize();
      final PdfGraphics graphics = page.graphics;

      // Invoice Header
      graphics.drawString(
        "Fathima Jewellery Works",
        notoSansBold,
        bounds: Rect.fromLTWH(0, 10, pageSize.width, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      graphics.drawString(
        "VP-9/384 PT Building, Gandhidaspadi, VENGARA - 676304, Malappuram (Dt.)",
        notoSansSmall,
        bounds: Rect.fromLTWH(0, 40, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      graphics.drawString(
        "GSTIN: 32CSRPP9658N1ZK",
        notoSansSmall,
        bounds: Rect.fromLTWH(0, 60, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );

      // Invoice Details
      graphics.drawString(
        "Invoice No: $invoiceId",
        notoSansFont,
        bounds: Rect.fromLTWH(0, 90, 200, 20),
      );
      graphics.drawString(
        "Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}",
        notoSansFont,
        bounds: Rect.fromLTWH(pageSize.width - 150, 90, 150, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
      graphics.drawString(
        "State: Kerala | State Code: 32",
        notoSansFont,
        bounds: Rect.fromLTWH(0, 110, pageSize.width, 20),
      );

      // Recipient Details
      graphics.drawString(
        "Details of the Recipient:",
        PdfTrueTypeFont(fontBytes, 14, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(0, 140, pageSize.width, 20),
      );
      graphics.drawString(
        "Name: ",
        PdfTrueTypeFont(fontBytes, 12),
        bounds: Rect.fromLTWH(0, 160, pageSize.width, 20),
      );
      graphics.drawString(
        recipientName,
        PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(50, 160, pageSize.width, 20),
      );
      graphics.drawString(
        "Address: ",
        PdfTrueTypeFont(fontBytes, 12),
        bounds: Rect.fromLTWH(0, 180, pageSize.width, 20),
      );
      graphics.drawString(
        recipientAddress,
        PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(50, 180, pageSize.width, 20),
      );
      graphics.drawString(
        "Place: ",
        PdfTrueTypeFont(fontBytes, 12),
        bounds: Rect.fromLTWH(0, 200, pageSize.width, 20),
      );
      graphics.drawString(
        recipientPlace,
        PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(50, 200, pageSize.width, 20),
      );
      graphics.drawString(
        "GSTIN: ",
        PdfTrueTypeFont(fontBytes, 12),
        bounds: Rect.fromLTWH(0, 220, pageSize.width, 20),
      );
      graphics.drawString(
        gstin,
        PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(50, 220, pageSize.width, 20),
      );

      // Spacing before product table
      double recipientDetailsBottom = 230;
      double extraSpace = 30;
      recipientDetailsBottom += extraSpace;

      // Create the product table
      final PdfGrid grid = PdfGrid();
      grid.columns.add(count: 10);

      double tableWidth = pageSize.width * 0.95;
      double leftMargin = 0;

      // Set custom column widths as percentages of tableWidth
      grid.columns[0].width = tableWidth * 0.05; // Sl No.
      grid.columns[1].width = tableWidth * 0.14; // Description
      grid.columns[2].width = tableWidth * 0.12; // HSN Code
      grid.columns[3].width = tableWidth * 0.12; // Unit of Measure
      grid.columns[4].width = tableWidth * 0.11; // Gross Weight
      grid.columns[5].width = tableWidth * 0.10; // Stone Weight
      grid.columns[6].width = tableWidth * 0.11; // Net Weight
      grid.columns[7].width = tableWidth * 0.08; // Rate per Gram
      grid.columns[8].width = tableWidth * 0.10; // Stone Charge
      grid.columns[9].width = tableWidth * 0.12; // Taxable Value

      grid.headers.add(1);

      final List<String> headers = [
        "Sl No.",
        "Description",
        "HSN Code",
        "Unit of Measure",
        "Gross Weight",
        "Stone Weight",
        "Net Weight",
        "Rate per Gram",
        "Stone Charge",
        "Taxable Value",
      ];

      final PdfGridRow header = grid.headers[0];
      for (int i = 0; i < headers.length; i++) {
        header.cells[i].value = headers[i];
        header.cells[i].style = PdfGridCellStyle(
          font: PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
          format: PdfStringFormat(alignment: PdfTextAlignment.center),
          cellPadding: PdfPaddings(left: 0, right: 0, top: 5, bottom: 5),
        );
      }

      // Add Product Rows and Calculate Totals
      double totalGrossWeight = 0;
      double totalStoneWeight = 0;
      double totalNetWeight = 0;
      double totalBeforeTax = 0;

      for (int i = 0; i < products.length; i++) {
        double taxableValue =
            double.tryParse(
              products[i]["taxable_value"]?.toString() ?? "0.0",
            ) ??
            0.0;
        String formattedTaxableValue = taxableValue.toStringAsFixed(2);

        // Truncate description with ellipsis if it exceeds column width
        String description = products[i]["description"] ?? "N/A";
        description = truncateTextWithEllipsis(
          text: description,
          font: notoSansFont,
          maxWidth:
              grid.columns[1].width - 4, // Subtract padding (left: 2, right: 2)
        );

        List<dynamic> productValues = [
          (i + 1).toString(),
          description,
          products[i]["hsn_code"] ?? "N/A",
          products[i]["unit_of_measure"] ?? "N/A",
          products[i]["gross_weight"]?.toString() ?? "0.0",
          products[i]["stone_weight"]?.toString() ?? "0.0",
          products[i]["net_weight"]?.toString() ?? "0.0",
          products[i]["rate_per_gram"]?.toString() ?? "0.0",
          products[i]["stone_charge"]?.toString() ?? "0.0",
          formattedTaxableValue,
        ];

        final PdfGridRow row = grid.rows.add();
        for (int j = 0; j < productValues.length; j++) {
          row.cells[j].value = productValues[j];
          row.cells[j].style = PdfGridCellStyle(
            font: notoSansFont,
            format: PdfStringFormat(
              alignment:
                  j == 1 ? PdfTextAlignment.left : PdfTextAlignment.center,
              wordWrap: j == 1 ? PdfWordWrapType.none : PdfWordWrapType.word,
            ),
            cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
          );
        }

        totalGrossWeight +=
            double.tryParse(products[i]["gross_weight"]?.toString() ?? "0.0") ??
            0.0;
        totalStoneWeight +=
            double.tryParse(products[i]["stone_weight"]?.toString() ?? "0.0") ??
            0.0;
        totalNetWeight +=
            double.tryParse(products[i]["net_weight"]?.toString() ?? "0.0") ??
            0.0;
        totalBeforeTax += taxableValue;
      }

      // Add a single Total row
      final PdfGridRow totalRow = grid.rows.add();
      totalRow.cells[0].value = "Total";
      totalRow.cells[0].style = PdfGridCellStyle(
        font: notoSansFont,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        cellPadding: PdfPaddings(left: 4, right: 2, top: 2, bottom: 2),
      );
      totalRow.cells[0].columnSpan =
          4; // Span across Sl No., Description, HSN Code, Unit of Measure

      totalRow.cells[4].value = totalGrossWeight.toStringAsFixed(2);
      totalRow.cells[4].style = PdfGridCellStyle(
        font: notoSansFont,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
      );

      totalRow.cells[5].value = totalStoneWeight.toStringAsFixed(2);
      totalRow.cells[5].style = PdfGridCellStyle(
        font: notoSansFont,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
      );

      totalRow.cells[6].value = totalNetWeight.toStringAsFixed(2);
      totalRow.cells[6].style = PdfGridCellStyle(
        font: notoSansFont,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
      );

      totalRow.cells[7].value = ""; // Rate per Gram (no total needed)
      totalRow.cells[7].style = PdfGridCellStyle(
        font: notoSansFont,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
      );

      totalRow.cells[8].value = ""; // Stone Charge (no total needed)
      totalRow.cells[8].style = PdfGridCellStyle(
        font: notoSansFont,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
      );

      totalRow.cells[9].value = totalBeforeTax.toStringAsFixed(2);
      totalRow.cells[9].style = PdfGridCellStyle(
        font: notoSansFont,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
      );

      // Taxes and Totals Calculation
      double cgst = totalBeforeTax * (cgstPercentage / 100);
      double sgst = totalBeforeTax * (sgstPercentage / 100);
      double igst = cgst + sgst;
      double totalAfterTax = totalBeforeTax + cgst + sgst;
      int totalAfterTaxFixed = totalAfterTax.toInt();

      // Use helper function to convert totalAfterTax to words
      String amountInWords = convertAmountToWords(totalAfterTax);

      // Add a row for Amount in Words
      final PdfGridRow amountInWordsRow = grid.rows.add();
      amountInWordsRow.cells[0].value = "Amount in Words:";
      amountInWordsRow.cells[0].columnSpan = 2; // Merge first two columns
      amountInWordsRow.cells[0].style = PdfGridCellStyle(
        font: notoSansFont,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
        cellPadding: PdfPaddings(left: 4, right: 2, top: 2, bottom: 2),
      );
      amountInWordsRow.cells[2].value = amountInWords;
      amountInWordsRow.cells[2].columnSpan = 8; // Merge remaining eight columns
      amountInWordsRow.cells[2].style = PdfGridCellStyle(
        font: notoSansFont,
        format: PdfStringFormat(
          alignment: PdfTextAlignment.left,
          wordWrap: PdfWordWrapType.word, // Enable word wrapping
        ),
        cellPadding: PdfPaddings(left: 4, right: 2, top: 2, bottom: 2),
      );

      // Draw the product table (now including Total and Amount in Words)
      PdfLayoutResult gridResult =
          grid.draw(
            page: page,
            bounds: Rect.fromLTWH(
              leftMargin,
              recipientDetailsBottom,
              tableWidth,
              0,
            ),
          )!;

      // Positioning variables for remaining sections
      double rightMargin = 5;
      double bankDetailsWidth =
          pageSize.width - 10; // Match table width minus margins
      double labelWidth = 70; // Width for bank detail labels
      double valueStartX =
          labelWidth + 10; // Starts after label with a 10-point gap

      // Calculate starting position for Bank Details
      double bankDetailsStartY =
          gridResult.bounds.bottom + 20; // 20 points below the grid

      // Draw Bank Details section
      graphics.drawString(
        "Bank Details:",
        PdfTrueTypeFont(fontBytes, 14, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(0, bankDetailsStartY, bankDetailsWidth, 20),
      );

      graphics.drawString(
        "Bank Name: ",
        PdfTrueTypeFont(fontBytes, 12),
        bounds: Rect.fromLTWH(0, bankDetailsStartY + 20, labelWidth, 20),
      );
      graphics.drawString(
        DefaultValues.bankName,
        PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
          valueStartX,
          bankDetailsStartY + 20,
          bankDetailsWidth - valueStartX,
          20,
        ),
        format: PdfStringFormat(wordWrap: PdfWordWrapType.word),
      );

      graphics.drawString(
        "Account Name: ",
        PdfTrueTypeFont(fontBytes, 12),
        bounds: Rect.fromLTWH(0, bankDetailsStartY + 40, labelWidth, 20),
      );
      graphics.drawString(
        DefaultValues.accountName,
        PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
          valueStartX,
          bankDetailsStartY + 40,
          bankDetailsWidth - valueStartX,
          20,
        ),
        format: PdfStringFormat(wordWrap: PdfWordWrapType.word),
      );

      graphics.drawString(
        "Account No: ",
        PdfTrueTypeFont(fontBytes, 12),
        bounds: Rect.fromLTWH(0, bankDetailsStartY + 60, labelWidth, 20),
      );
      graphics.drawString(
        DefaultValues.accountNo,
        PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
          valueStartX,
          bankDetailsStartY + 60,
          bankDetailsWidth - valueStartX,
          20,
        ),
        format: PdfStringFormat(wordWrap: PdfWordWrapType.word),
      );

      graphics.drawString(
        "IFSC Code: ",
        PdfTrueTypeFont(fontBytes, 12),
        bounds: Rect.fromLTWH(0, bankDetailsStartY + 80, labelWidth, 20),
      );
      graphics.drawString(
        DefaultValues.ifscCode,
        PdfTrueTypeFont(fontBytes, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
          valueStartX,
          bankDetailsStartY + 80,
          bankDetailsWidth - valueStartX,
          20,
        ),
        format: PdfStringFormat(wordWrap: PdfWordWrapType.word),
      );

      // Tax Grid
      final PdfGrid taxGrid = PdfGrid();
      taxGrid.columns.add(count: 2);
      List<Map<String, dynamic>> taxData = [
        {"label": "Total Amount Before Tax: ", "value": totalBeforeTax},
        {"label": "Add:CGST ($cgstPercentage%): ", "value": cgst},
        {"label": "Add:SGST ($sgstPercentage%): ", "value": sgst},
        {"label": "Add:IGST: ", "value": igst},
        {"label": "Add: CESS: ", "value": ''},
        {"label": "Total Amount Including Tax: ", "value": totalAfterTaxFixed},
        {"label": "GST Payable on Reverse Charge: ", "value": ''},
        {"label": "", "value": ''},
        {"label": "", "value": ''},
        {"label": "Authorized signature :", "value": ''},
      ];

      double firstColumnWidth = 170;
      double secondColumnWidth = 100;
      double taxTableWidth = firstColumnWidth + secondColumnWidth;

      taxGrid.columns[0].width = firstColumnWidth;
      taxGrid.columns[1].width = secondColumnWidth;

      taxGrid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 0, right: 0, top: 0, bottom: 0),
        cellSpacing: 0,
      );

      for (var item in taxData) {
        final PdfGridRow row = taxGrid.rows.add();
        row.cells[0].value = item["label"];
        String formattedValue = '';
        if (item["value"] is double) {
          formattedValue = "₹${item["value"].toStringAsFixed(2)}";
        } else if (item["value"] is int) {
          formattedValue =
              "₹${item["value"].toString()}"; // Handle integer values
        } else {
          formattedValue =
              item["value"].toString(); // Fallback for empty or other types
        }
        row.cells[1].value = formattedValue;
        row.cells[0].style = PdfGridCellStyle(
          font: notoSansFont,
          format: PdfStringFormat(alignment: PdfTextAlignment.left),
          cellPadding: PdfPaddings(left: 3, right: 0, top: 3, bottom: 3),
          borders: PdfBorders(
            left: PdfPen(PdfColor(0, 0, 0, 0), width: 0),
            right: PdfPen(PdfColor(0, 0, 0, 0), width: 0),
            top: PdfPen(PdfColor(0, 0, 0, 0), width: 0),
            bottom: PdfPen(PdfColor(0, 0, 0, 0), width: 0),
          ),
        );
        row.cells[1].style = PdfGridCellStyle(
          font: notoSansFont,
          format: PdfStringFormat(alignment: PdfTextAlignment.right),
          cellPadding: PdfPaddings(left: 0, right: 3, top: 3, bottom: 3),
          borders: PdfBorders(
            left: PdfPen(PdfColor(0, 0, 0, 0), width: 0),
            right: PdfPen(PdfColor(0, 0, 0, 0), width: 0),
            top: PdfPen(PdfColor(0, 0, 0, 0), width: 0),
            bottom: PdfPen(PdfColor(0, 0, 0, 0), width: 0),
          ),
        );
      }

      taxGrid.draw(
        page: page,
        bounds: Rect.fromLTWH(
          pageSize.width - rightMargin - taxTableWidth,
          gridResult.bounds.bottom + 10,
          taxTableWidth,
          0,
        ),
      );

      // // Draw 'Authorized signature' at the bottom right corner
      // graphics.drawString(
      //   "Authorized signature",
      //   notoSansSmall,
      //   bounds: Rect.fromLTWH(0, pageSize.height - 30, pageSize.width - 10, 20),
      //   format: PdfStringFormat(alignment: PdfTextAlignment.right),
      // );

      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = "${directory.path}/invoice_$invoiceId.pdf";
      final File file = File(filePath);
      await file.writeAsBytes(await document.save());

      document.dispose();
      isShare
          ? Share.shareXFiles([XFile(filePath)], text: "Invoice $invoiceId")
          : OpenFilex.open(filePath);
    } catch (e) {
      print("Exception: Failed to generate PDF: $e");
    }
  }
}
