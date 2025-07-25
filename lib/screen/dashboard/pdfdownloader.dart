import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hpackweb/models/customerModel.dart';
import 'package:hpackweb/models/pricelistModel.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfDownloadService {
  // Private constructor
  PdfDownloadService._privateConstructor();

  // Singleton instance
  static final PdfDownloadService _instance =
      PdfDownloadService._privateConstructor();

  // Getter
  static PdfDownloadService get instance => _instance;

  // Function to generate and download approved price list
  Future<void> downloadApprovedPdfWeb({
    required CustomerModel? customer,
    required List<PriceListModel> priceList,
  }) async {
    final document = PdfDocument();

    document.pageSettings.orientation = PdfPageOrientation.landscape;
    document.pageSettings.size = PdfPageSize.a4;

    final page = document.pages.add();

    final regularFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final boldFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
      style: PdfFontStyle.bold,
    );

    const double margin = 20;
    double yOffset = margin;

    // Load logo
    final ByteData logoData = await rootBundle.load(
      'assets/images/hpacklogo.png',
    );
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final PdfBitmap logoImage = PdfBitmap(logoBytes);
    page.graphics.drawImage(logoImage, Rect.fromLTWH(margin, yOffset, 100, 40));

    yOffset += 50;

    // Header
    page.graphics.drawString(
      'Customer Name: ${customer?.cardName ?? ''}',
      boldFont,
      bounds: Rect.fromLTWH(margin, yOffset, 500, 20),
    );
    yOffset += 20;

    page.graphics.drawString(
      'Shipping Address: ${customer?.shippingFullAddress ?? ''}',
      regularFont,
      bounds: Rect.fromLTWH(margin, yOffset, 500, 20),
    );
    yOffset += 20;

    page.graphics.drawString(
      'Billing Address: ${customer?.billingFullAddress ?? ''}',
      regularFont,
      bounds: Rect.fromLTWH(margin, yOffset, 500, 20),
    );
    yOffset += 30;

    // Grid
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 7);
    grid.headers.add(1);
    final headerRow = grid.headers[0];
    final headers = [
      'Item Code',
      'Item Name',
      'Case Size',
      'Pallet Qty',
      'Updated Price',
      'EPR Value',
      'New Price',
    ];

    for (int i = 0; i < headers.length; i++) {
      headerRow.cells[i].value = headers[i];
      headerRow.cells[i].style = PdfGridCellStyle(
        backgroundBrush: PdfBrushes.lightGray,
        textBrush: PdfBrushes.black,
        font: boldFont,
        cellPadding: PdfPaddings(left: 5, right: 5, top: 3, bottom: 3),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        ),
      );
    }

    final approvedItems =
        priceList
            .where((e) => e.updatedPrice != null && e.updatedPrice! > 0)
            .toList();

    for (var item in approvedItems) {
      final row = grid.rows.add();
      row.cells[0].value = item.itemCode ?? '';
      row.cells[1].value = item.itemName ?? '';
      row.cells[2].value = item.uCaseSize ?? '';
      row.cells[3].value = item.uPalletQty?.toStringAsFixed(0) ?? '';
      row.cells[4].value = item.updatedPrice?.toStringAsFixed(2) ?? '';
      row.cells[5].value = item.eprValue?.toStringAsFixed(2) ?? '';
      row.cells[6].value = item.newPrice?.toStringAsFixed(2) ?? '';

      for (int i = 0; i < row.cells.count; i++) {
        row.cells[i].style = PdfGridCellStyle(
          font: regularFont,
          format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle,
          ),
        );
      }
    }

    // Set column widths
    final widths = [100.0, 200.0, 70.0, 80.0, 90.0, 90.0, 100.0];
    for (int i = 0; i < widths.length; i++) {
      grid.columns[i].width = widths[i];
    }

    final pageWidth = document.pageSettings.size.width - (2 * margin);
    grid.draw(page: page, bounds: Rect.fromLTWH(margin, yOffset, pageWidth, 0));

    final bytes = await document.save();
    document.dispose();

    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', 'ApprovedPriceList.pdf')
          ..click();
    html.Url.revokeObjectUrl(url);
  }
}
