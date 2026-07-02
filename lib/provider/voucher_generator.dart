import 'dart:io';
import 'package:flutter/services.dart';
import 'package:invoice_maker/model/voucher_item.dart';
import 'package:invoice_maker/utils/first_word.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';

class VoucherGenerator {
  Future<void> createVoucher({
    required String voucherId,
    required String name,
    required String gstin,
    required DateTime date,
    required List<VoucherItem> items,
    required bool isShare,
    int issuedGrossWtDp = 3,
    int touchDp = 3,
    int issuedNetWtDp = 3,
  }) async {
    try {
      final ByteData fontData = await rootBundle.load(
        "assets/fonts/NotoSans-Regular.ttf",
      );
      final Uint8List fontBytes = fontData.buffer.asUint8List();

      final PdfFont notoSansBold22 = PdfTrueTypeFont(
        fontBytes,
        22,
        style: PdfFontStyle.bold,
      );
      final PdfFont notoSansBold12 = PdfTrueTypeFont(
        fontBytes,
        12,
        style: PdfFontStyle.bold,
      );
      final PdfFont notoSansBold14 = PdfTrueTypeFont(
        fontBytes,
        14,
        style: PdfFontStyle.bold,
      );
      final PdfFont notoSansSmall = PdfTrueTypeFont(fontBytes, 10);
      final PdfFont notoSans12 = PdfTrueTypeFont(fontBytes, 12);
      final PdfFont notoSans8 = PdfTrueTypeFont(fontBytes, 8);
      final PdfFont notoSans8Bold = PdfTrueTypeFont(
        fontBytes,
        8,
        style: PdfFontStyle.bold,
      );

      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final Size pageSize = page.getClientSize();
      final PdfGraphics graphics = page.graphics;

      double y = 5;

      // ── Header ──────────────────────────────────────────────────────────
      graphics.drawString(
        "Fathima Jewellery Works",
        notoSansBold22,
        bounds: Rect.fromLTWH(0, y, pageSize.width, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      y += 38;

      graphics.drawString(
        "VP-9/384 PT Building, Gandhidaspadi, VENGARA - 676304, Malappuram (Dt.)",
        notoSansSmall,
        bounds: Rect.fromLTWH(0, y, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      y += 18;

      graphics.drawString(
        "Mob:9605 700 100                    GSTIN: 32CSRPP9658N1ZK",
        notoSansSmall,
        bounds: Rect.fromLTWH(0, y, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      y += 22;

      // ── Horizontal rule ─────────────────────────────────────────────────
      graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 0.5),
        Offset(0, y),
        Offset(pageSize.width, y),
      );
      y += 8;

      // ── Title ────────────────────────────────────────────────────────────
      graphics.drawString(
        "SMITH ISSUE VOUCHER",
        notoSansBold14,
        bounds: Rect.fromLTWH(0, y, pageSize.width, 22),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      y += 26;

      // ── Horizontal rule ─────────────────────────────────────────────────
      graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 0.5),
        Offset(0, y),
        Offset(pageSize.width, y),
      );
      y += 10;

      // ── Voucher number + date ────────────────────────────────────────────
      graphics.drawString(
        "Voucher No: $voucherId",
        notoSans12,
        bounds: Rect.fromLTWH(0, y, 250, 20),
      );
      graphics.drawString(
        "Date: ${DateFormat('dd-MM-yyyy').format(date)}",
        notoSans12,
        bounds: Rect.fromLTWH(pageSize.width - 160, y, 160, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
      y += 24;

      // ── Name + GSTIN ─────────────────────────────────────────────────────
      graphics.drawString(
        "Name: ",
        notoSansSmall,
        bounds: Rect.fromLTWH(0, y, 50, 20),
      );
      graphics.drawString(
        name,
        notoSans8Bold,
        bounds: Rect.fromLTWH(50, y, pageSize.width - 50, 20),
      );
      y += 18;

      graphics.drawString(
        "GSTIN: ",
        notoSansSmall,
        bounds: Rect.fromLTWH(0, y, 50, 20),
      );
      graphics.drawString(
        gstin,
        notoSans8Bold,
        bounds: Rect.fromLTWH(50, y, pageSize.width - 50, 20),
      );
      y += 24;

      // ── Items table ───────────────────────────────────────────────────────
      final PdfGrid grid = PdfGrid();
      grid.columns.add(count: 10);

      final double tableWidth = pageSize.width;
      grid.columns[0].width = tableWidth * 0.19; // Item Name
      grid.columns[1].width = tableWidth * 0.08; // HSN Code
      grid.columns[2].width = tableWidth * 0.05; // Qty.
      grid.columns[3].width = tableWidth * 0.13; // Issued Gr. Wgt.
      grid.columns[4].width = tableWidth * 0.10; // Received Gr. Wgt.
      grid.columns[5].width = tableWidth * 0.08; // Mud Less
      grid.columns[6].width = tableWidth * 0.08; // Touch
      grid.columns[7].width = tableWidth * 0.08; // MC / Amt
      grid.columns[8].width = tableWidth * 0.11; // Issued Net. Wgt
      grid.columns[9].width = tableWidth * 0.10; // Received Net. Wgt.

      grid.headers.add(1);
      final List<String> headers = [
        "Item Name",
        "HSN Code",
        "Qty.",
        "Issued Gr. Wgt.",
        "Received Gr. Wgt.",
        "Mud Less",
        "Touch",
        "MC / Amt",
        "Issued Net. Wgt",
        "Received Net. Wgt.",
      ];
      final PdfGridRow headerRow = grid.headers[0];
      for (int i = 0; i < headers.length; i++) {
        headerRow.cells[i].value = headers[i];
        headerRow.cells[i].style = PdfGridCellStyle(
          font: notoSans8Bold,
          format: PdfStringFormat(alignment: PdfTextAlignment.center),
          backgroundBrush: PdfSolidBrush(PdfColor(220, 220, 220)),
          cellPadding: PdfPaddings(left: 2, right: 2, top: 5, bottom: 5),
        );
      }

      double totalIssuedNetWeight = 0;

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final PdfGridRow row = grid.rows.add();
        row.cells[0].value = item.itemName;
        row.cells[1].value = item.hsnCode;
        row.cells[2].value = '';
        row.cells[3].value = item.issuedGrossWeight.toStringAsFixed(
          issuedGrossWtDp,
        );
        row.cells[4].value = '';
        row.cells[5].value = '';
        row.cells[6].value = item.touch.toStringAsFixed(touchDp);
        row.cells[7].value = '';
        row.cells[8].value = item.issuedNetWeight.toStringAsFixed(
          issuedNetWtDp,
        );
        row.cells[9].value = '';

        for (int j = 0; j < 10; j++) {
          row.cells[j].style = PdfGridCellStyle(
            font: notoSans8,
            format: PdfStringFormat(
              alignment:
                  j == 0 ? PdfTextAlignment.left : PdfTextAlignment.center,
              wordWrap:
                  j == 0 ? PdfWordWrapType.character : PdfWordWrapType.word,
            ),
            cellPadding: PdfPaddings(left: 2, right: 2, top: 3, bottom: 3),
          );
        }

        totalIssuedNetWeight += item.totalIssuedNetWeight;

        if (item.copperGrossWeight != null || item.copperNetWeight != null) {
          final PdfGridRow copperRow = grid.rows.add();
          copperRow.cells[0].value = 'COPPER';
          copperRow.cells[1].value = '';
          copperRow.cells[2].value = '';
          copperRow.cells[3].value =
              item.copperGrossWeight?.toStringAsFixed(issuedGrossWtDp) ?? '';
          copperRow.cells[4].value = '';
          copperRow.cells[5].value = '';
          copperRow.cells[6].value = '';
          copperRow.cells[7].value = '';
          copperRow.cells[8].value =
              item.copperNetWeight?.toStringAsFixed(issuedNetWtDp) ?? '';
          copperRow.cells[9].value = '';

          for (int j = 0; j < 10; j++) {
            copperRow.cells[j].style = PdfGridCellStyle(
              font: notoSans8,
              format: PdfStringFormat(
                alignment:
                    j == 0 ? PdfTextAlignment.left : PdfTextAlignment.center,
                wordWrap:
                    j == 0 ? PdfWordWrapType.character : PdfWordWrapType.word,
              ),
              cellPadding: PdfPaddings(left: 2, right: 2, top: 3, bottom: 3),
            );
          }
        }
      }

      // Total row
      final PdfGridRow totalRow = grid.rows.add();
      totalRow.cells[0].value = "Total";
      totalRow.cells[0].columnSpan = 8;
      totalRow.cells[0].style = PdfGridCellStyle(
        font: notoSans8Bold,
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        cellPadding: PdfPaddings(left: 4, right: 4, top: 3, bottom: 3),
      );
      totalRow.cells[8].value = totalIssuedNetWeight.toStringAsFixed(
        issuedNetWtDp,
      );
      totalRow.cells[8].style = PdfGridCellStyle(
        font: notoSans8Bold,
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
        cellPadding: PdfPaddings(left: 2, right: 2, top: 3, bottom: 3),
      );

      final PdfLayoutResult gridResult =
          grid.draw(page: page, bounds: Rect.fromLTWH(0, y, tableWidth, 0))!;

      // ── Footer ────────────────────────────────────────────────────────────
      final double footerY = gridResult.bounds.bottom + 30;

      graphics.drawString(
        "Signature",
        notoSansBold12,
        bounds: Rect.fromLTWH(0, footerY, 150, 20),
      );
      graphics.drawString(
        "Authorised Signatory",
        notoSansBold12,
        bounds: Rect.fromLTWH(pageSize.width - 160, footerY, 160, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );

      // ── Save / Share ──────────────────────────────────────────────────────
      final String firstName = getFirstWord(name);
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath =
          "${directory.path}/voucher_${firstName}_$voucherId.pdf";
      final File file = File(filePath);
      await file.writeAsBytes(await document.save());
      document.dispose();

      if (isShare) {
        Share.shareXFiles([XFile(filePath)], text: "Voucher $voucherId");
      } else {
        OpenFilex.open(filePath);
      }
    } catch (e) {
      print("VoucherGenerator error: $e");
    }
  }
}
