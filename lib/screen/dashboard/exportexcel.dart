import 'dart:typed_data';
import 'dart:html' as html;
import 'package:hpackweb/models/customerModel.dart';
import 'package:hpackweb/models/pdfmodel.dart';
import 'package:hpackweb/models/pricelistModel.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class ExcelExporter {
  // 🔁 Singleton pattern
  static final ExcelExporter _instance = ExcelExporter._internal();
  factory ExcelExporter() => _instance;
  ExcelExporter._internal();

  Future<void> exportPriceListWithHeader({
    required List<PdfListModel> data,
    required CustomerModel? customer,
  }) async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    int rowIndex = 1;

    // 🧾 Header info
    sheet
        .getRangeByIndex(rowIndex++, 1)
        .setText("Customer Name: ${customer?.cardName}");
    sheet
        .getRangeByIndex(rowIndex++, 1)
        .setText("Shipping Address: ${customer?.shippingFullAddress}");
    sheet
        .getRangeByIndex(rowIndex++, 1)
        .setText("Billing Address: ${customer?.billingFullAddress}");

    rowIndex++; // spacer

    // 📊 Column headers
    final headers = [
      'Item Code',
      'Item Name',
      'Brand',
      'Case Size',
      'Pallet Qty',
      'Current Price',
      'Updated Price',
      'EPR',
      'New Price',
    ];

    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(rowIndex, i + 1).setText(headers[i]);
    }

    rowIndex++;

    // 🧾 Row data
    for (final item in data.where((e) => !e.isGroupHeader)) {
      sheet.getRangeByIndex(rowIndex, 1).setText(item.itemCode ?? '');
      sheet.getRangeByIndex(rowIndex, 2).setText(item.itemName ?? '');
      sheet.getRangeByIndex(rowIndex, 3).setText(item.uBrand ?? '');
      sheet.getRangeByIndex(rowIndex, 4).setText(item.uCaseSize ?? '');
      sheet
          .getRangeByIndex(rowIndex, 5)
          .setText((item.uPalletQty ?? 0).toStringAsFixed(2));
      sheet
          .getRangeByIndex(rowIndex, 6)
          .setText((item.casePrice ?? 0).toStringAsFixed(2));
      sheet
          .getRangeByIndex(rowIndex, 7)
          .setText((item.updatedPrice ?? 0).toStringAsFixed(2));
      sheet
          .getRangeByIndex(rowIndex, 8)
          .setText((item.eprValue ?? 0).toStringAsFixed(2));
      sheet
          .getRangeByIndex(rowIndex, 9)
          .setText((item.newPrice ?? 0).toStringAsFixed(2));
      rowIndex++;
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final Uint8List byteData = Uint8List.fromList(bytes);
    final blob = html.Blob([byteData]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', 'PriceListExport.xlsx')
          ..click();
    html.Url.revokeObjectUrl(url);
  }
}
