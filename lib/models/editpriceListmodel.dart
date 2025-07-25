// // import 'pricelistModel.dart';

// // class EditPriceListModel {
// //   final int docEntry;
// //   final String cardCode;
// //   final String cardName;
// //   final String priceListNum;
// //   final String priceListName;
// //   final String effectiveDate;
// //   final String percentage;
// //   final String createdBy;
// //   final String createdDate;
// //   final String approvedByID;
// //   final String? approvedByName;
// //   final String appovedStatus;
// //   final String? remarks;
// //   final String status;
// //   final List<PriceListModel>? details;

// //   EditPriceListModel({
// //     required this.docEntry,
// //     required this.cardCode,
// //     required this.cardName,
// //     required this.priceListNum,
// //     required this.priceListName,
// //     required this.effectiveDate,
// //     required this.percentage,
// //     required this.createdBy,
// //     required this.createdDate,
// //     required this.approvedByID,
// //     required this.approvedByName,
// //     required this.appovedStatus,
// //     required this.remarks,
// //     required this.status,
// //     required this.details,
// //   });

// //   factory EditPriceListModel.fromJson(Map<String, dynamic> json) {
// //     return EditPriceListModel(
// //       docEntry: json['DocEntry'] ?? 0,
// //       cardCode: json['CardCode'] ?? '',
// //       cardName: json['CardName'] ?? '',
// //       priceListNum: json['PriceListNum'] ?? '',
// //       priceListName: json['PriceListName'] ?? '',
// //       effectiveDate: json['EffectiveDate'] ?? '',
// //       percentage: json['Percentage'] ?? '',
// //       createdBy: json['CreatedBy'] ?? '',
// //       createdDate: json['CreatedDate'] ?? '',
// //       approvedByID: json['ApprovedByID'] ?? '',
// //       approvedByName: json['ApprovedByName'],
// //       appovedStatus: json['AppovedStatus'] ?? '',
// //       remarks: json['Remarks'],
// //       status: json['Status'] ?? '',
// //       details:
// //           (json['details'] as List<dynamic>?)
// //               ?.map((item) => PriceListModel.fromJson(item))
// //               .toList(),
// //     );
// //   }

// //   Map<String, dynamic> toJson() => {
// //     'DocEntry': docEntry,
// //     'CardCode': cardCode,
// //     'CardName': cardName,
// //     'PriceListNum': priceListNum,
// //     'PriceListName': priceListName,
// //     'EffectiveDate': effectiveDate,
// //     'Percentage': percentage,
// //     'CreatedBy': createdBy,
// //     'CreatedDate': createdDate,
// //     'ApprovedByID': approvedByID,
// //     'ApprovedByName': approvedByName,
// //     'AppovedStatus': appovedStatus,
// //     'Remarks': remarks,
// //     'Status': status,
// //     'details': details?.map((item) => item.toJson()).toList(),
// //   };
// // }

// class EditPriceListHeaderModel {
//   int docEntry;
//   String cardCode;
//   String cardName;
//   String billingAddress;
//   String shippingAddres;
//   String priceListNum;
//   String priceListName;
//   String effectiveDate;
//   String createdBy;
//   String createdDate;
//   String approvedById;
//   String? approvedByName;
//   String approvedStatus;
//   String? remarks;
//   String status;
//   List<EditPriceListDetailsModel>? details;

//   EditPriceListHeaderModel({
//     required this.docEntry,
//     required this.cardCode,
//     required this.cardName,
//     required this.billingAddress,
//     required this.shippingAddres,

//     required this.priceListNum,
//     required this.priceListName,
//     required this.effectiveDate,
//     required this.createdBy,
//     required this.createdDate,
//     required this.approvedById,
//     this.approvedByName,
//     required this.approvedStatus,
//     this.remarks,
//     required this.status,
//     this.details,
//   });

//   factory EditPriceListHeaderModel.fromJson(Map<String, dynamic> json) {
//     return EditPriceListHeaderModel(
//       docEntry: json['DocEntry'] ?? 0,
//       cardCode: json['CardCode'] ?? '',
//       cardName: json['CardName'] ?? '',
//       billingAddress: json['BillingAddress'] ?? '',
//       shippingAddres: json['ShippingAddress'] ?? '',
//       priceListNum: json['PriceListNum'] ?? '',
//       priceListName: json['PriceListName'] ?? '',
//       effectiveDate: json['EffectiveDate'] ?? '',
//       createdBy: json['CreatedBy'] ?? '',
//       createdDate: json['CreatedDate'] ?? '',
//       approvedById: json['ApprovedByID'] ?? '',
//       approvedByName: json['ApprovedByName'],
//       approvedStatus: json['AppovedStatus'] ?? '',
//       remarks: json['Remarks'],
//       status: json['Status'] ?? '',
//       details:
//           (json['details'] as List<dynamic>?)
//               ?.map((e) => EditPriceListDetailsModel.fromJson(e))
//               .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'DocEntry': docEntry,
//       'CardCode': cardCode,
//       'CardName': cardName,
//       'BillingAddress': billingAddress,
//       'ShippingAddress': shippingAddres,
//       'PriceListNum': priceListNum,
//       'PriceListName': priceListName,
//       'EffectiveDate': effectiveDate,
//       'CreatedBy': createdBy,
//       'CreatedDate': createdDate,
//       'ApprovedByID': approvedById,
//       'ApprovedByName': approvedByName,
//       'AppovedStatus': approvedStatus,
//       'Remarks': remarks,
//       'Status': status,
//       'details': details?.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// class EditPriceListDetailsModel {
//   int rowNo;
//   int docEntry;
//   int lineID;
//   String uBrand;
//   double stock;
//   double committed;
//   double order;
//   double salesPrice;
//   double evaluatedPrice;
//   double casePrice;
//   double eprValue;
//   String itemCode;
//   String itemName;
//   String listNum;
//   String listName;
//   String uCaseSize;
//   String uItemsPerLayer;
//   String uLayersPerPallet;
//   double uPalletQty;
//   double updatedPrice;
//   double updatedPercentage;
//   double newPrice;
//   String isapproved;
//   double marginPercentage;
//   String category;
//   bool isCategoryHeader;
//   bool isHeaderRow;

//   EditPriceListDetailsModel({
//     required this.rowNo,
//     required this.docEntry,
//     required this.lineID,
//     required this.uBrand,
//     required this.stock,
//     required this.committed,
//     required this.order,
//     required this.salesPrice,
//     required this.evaluatedPrice,
//     required this.casePrice,
//     required this.eprValue,
//     required this.itemCode,
//     required this.itemName,
//     required this.listNum,
//     required this.listName,
//     required this.uCaseSize,
//     required this.uItemsPerLayer,
//     required this.uLayersPerPallet,
//     required this.uPalletQty,
//     required this.updatedPrice,
//     required this.updatedPercentage,
//     required this.newPrice,
//     required this.isapproved,
//     required this.marginPercentage,
//     required this.category,
//     this.isCategoryHeader = false,
//     this.isHeaderRow = false,
//   });

//   static double toDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }

//   static String toStringSafe(dynamic value) {
//     if (value == null) return '';
//     return value.toString();
//   }

//   factory EditPriceListDetailsModel.fromJson(Map<String, dynamic> json) {
//     final eval = toDouble(json['EvaluatePrice'] ?? json['evaluatedPrice']);
//     final percent = toDouble(json['Percentage'] ?? json['updatedPercentage']);
//     final updated =
//         json['UpdatedPrice'] != null
//             ? toDouble(json['UpdatedPrice'])
//             : (eval - (eval * percent / 100));
//     final newP =
//         json['NewPrice'] != null ? toDouble(json['NewPrice']) : (updated);
//     double ebaluateprice = toDouble(json['evaluatedPrice']);
//     double marginper = (updated - ebaluateprice) / updated;
//     return EditPriceListDetailsModel(
//       rowNo: json['RowNo'],
//       docEntry: json['DocEntry'],
//       lineID: json['LineID'],
//       uBrand: toStringSafe(json['Brand'] ?? json['u_Brand']),
//       stock: toDouble(json['Stock'] ?? json['stock']),
//       committed: toDouble(json['Committed'] ?? json['commited']),
//       order: toDouble(json['OnOrder'] ?? json['order']),
//       salesPrice: toDouble(json['SalesPrice'] ?? json['salesPrice']),
//       evaluatedPrice: eval,
//       casePrice: toDouble(json['CasePrice'] ?? json['casePrice']),
//       eprValue: toDouble(json['EPR'] ?? json['eprValue']),
//       itemCode: toStringSafe(json['ItemCode'] ?? json['itemCode']),
//       itemName: toStringSafe(json['ItemName'] ?? json['itemName']),
//       listNum: toStringSafe(json['PriceListNum'] ?? json['listNum']),
//       listName: toStringSafe(json['PriceListName'] ?? json['listName']),
//       uCaseSize: toStringSafe(json['CaseQty'] ?? json['u_Case_Size']),
//       uItemsPerLayer: toStringSafe(json['u_Items_per_Layer']),
//       uLayersPerPallet: toStringSafe(json['u_Layers_per_Pallet']),
//       uPalletQty: toDouble(json['PalletQty'] ?? json['u_Pallet_Qty']),
//       updatedPercentage: percent,
//       updatedPrice: updated,
//       newPrice: newP,
//       isapproved: toStringSafe(json['isapproved']),
//       marginPercentage: updated > 0 ? marginper : 0,
//       category: toStringSafe(json['Category'] ?? json['category']),
//       isCategoryHeader: json['isCategoryHeader'] ?? false,
//       isHeaderRow: json['isHeaderRow'] ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'RowNo': rowNo,
//       'DocEntry': docEntry,
//       'LineID': lineID,
//       'u_Brand': uBrand,
//       'stock': stock,
//       'commited': committed,
//       'order': order,
//       'salesPrice': salesPrice,
//       'evaluatedPrice': evaluatedPrice,
//       'itemCode': itemCode,
//       'itemName': itemName,
//       'listNum': listNum,
//       'listName': listName,
//       'u_Case_Size': uCaseSize,
//       'u_Items_per_Layer': uItemsPerLayer,
//       'u_Layers_per_Pallet': uLayersPerPallet,
//       'u_Pallet_Qty': uPalletQty,
//       'updatedPercentage': updatedPercentage,
//       'updatedPrice': updatedPrice,
//       'newPrice': newPrice,
//       'isapproved': isapproved,
//       'marginpercentage': marginPercentage,
//       'category': category,
//       'isCategoryHeader': isCategoryHeader,
//       'isHeaderRow': isHeaderRow,
//     };
//   }
// }

class EditPriceListModel {
  String? uBrand;
  String? rowNo;
  String? lineID;
  double? stock;
  double? committed;
  double? order;
  double? salesPrice;
  double? evaluatedPrice;
  double? casePrice;
  double? eprValue;
  String? itemCode;
  String? itemName;
  String? listNum;
  String? listName;
  String? uCaseSize;
  String? uItemsPerLayer;
  String? uLayersPerPallet;
  double? uPalletQty;
  double? updatedPrice;
  double? updatedPercentage;
  double? newPrice;
  String? isapproved;
  double? marginPercentage;
  String? category;
  bool isGroupHeader;

  EditPriceListModel({
    this.uBrand,
    this.rowNo,
    this.lineID,
    this.stock,
    this.committed,
    this.order,
    this.salesPrice,
    this.evaluatedPrice,
    this.casePrice,
    this.eprValue,
    this.itemCode,
    this.itemName,
    this.listNum,
    this.listName,
    this.uCaseSize,
    this.uItemsPerLayer,
    this.uLayersPerPallet,
    this.uPalletQty,
    this.updatedPrice,
    this.updatedPercentage,
    this.newPrice,
    this.isapproved,
    this.marginPercentage,
    this.category,
    this.isGroupHeader = false,
  });

  static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String toStringSafe(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // factory PriceListModel.fromJson(Map<String, dynamic> json) {
  //   double caseprice = toDouble(json['casePrice']);
  //   double percent = toDouble(json['updatedPercentage']);
  //   double evaluatePrice = toDouble(json['evaluatedPrice']);
  //   double updated =
  //       caseprice -
  //       (caseprice * percent / 100); // fix: percent should be divided
  //   double newP = caseprice + updated;
  //   double epr = toDouble(json['eprValue']);
  //   double marginPer =
  //       updated > 0 ? ((updated - evaluatePrice) / updated) * 100 : 0;

  //   return PriceListModel(
  //     uBrand: toStringSafe(json['u_Brand']),
  //     stock: toDouble(json['stock']),
  //     committed: toDouble(json['committed']), // ✅ typo fixed
  //     order: toDouble(json['order']),
  //     salesPrice: toDouble(json['salesPrice']),
  //     evaluatedPrice: evaluatePrice,
  //     casePrice: caseprice,
  //     eprValue: epr,
  //     itemCode: toStringSafe(json['itemCode']),
  //     itemName: toStringSafe(json['itemName']),
  //     listNum: toStringSafe(json['listNum']),
  //     listName: toStringSafe(json['listName']),
  //     uCaseSize: toStringSafe(json['u_Case_Size']),
  //     uItemsPerLayer: toStringSafe(json['u_Items_per_Layer']),
  //     uLayersPerPallet: toStringSafe(json['u_Layers_per_Pallet']),
  //     uPalletQty: toDouble(json['u_Pallet_Qty']),
  //     updatedPercentage: percent,
  //     updatedPrice: updated,
  //     newPrice: newP,
  //     isapproved: toStringSafe(json['isapproved']),
  //     marginPercentage: marginPer,
  //     category: toStringSafe(json['category']),
  //   );
  // }

  factory EditPriceListModel.fromJson(Map<String, dynamic> json) {
    double caseprice = toDouble(json['CasePrice']);
    double percent = toDouble(json['Percentage']);
    double evaluatePrice = toDouble(json['EvaluatePrice']);
    double updated = caseprice - (caseprice * percent / 100);
    double newP = caseprice + updated;
    double epr = toDouble(json['EPR']);
    double marginPer =
        updated > 0 ? ((updated - evaluatePrice) / updated) * 100 : 0;

    return EditPriceListModel(
      uBrand: toStringSafe(json['Brand']),
      rowNo: toStringSafe(json['RowNo'] ?? "0"),
      lineID: toStringSafe(json['LineID'] ?? "0"),
      stock: toDouble(json['Stock']),
      committed: toDouble(json['Committed']),
      order: toDouble(json['OnOrder']),
      salesPrice: toDouble(json['SalesPrice']),
      evaluatedPrice: evaluatePrice,
      casePrice: caseprice,
      eprValue: epr,
      itemCode: toStringSafe(json['ItemCode']),
      itemName: toStringSafe(json['ItemName']),
      listNum: toStringSafe(json['PriceListNum']),
      listName: toStringSafe(json['PriceListName']),
      uCaseSize: toStringSafe(json['CaseQty']),
      uItemsPerLayer: toStringSafe(json['u_Items_per_Layer']),
      uLayersPerPallet: toStringSafe(json['u_Layers_per_Pallet']),
      uPalletQty: toDouble(json['PalletQty']),
      updatedPercentage: percent,
      updatedPrice: updated,
      newPrice: newP,
      isapproved: toStringSafe(json['isapproved']),
      marginPercentage: marginPer,
      category: toStringSafe(json['category'] ?? json['Category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Brand': uBrand,
      'RowNo': rowNo,
      'LineID': lineID,
      'Stock': stock,
      'Commited': committed,
      'Order': order,
      'SalesPrice': salesPrice,
      'EvaluatePrice': evaluatedPrice,
      'ItemCode': itemCode,
      'ItemName': itemName,
      'PriceListNum': listNum,
      'PriceListName': listName,
      'CaseQty': uCaseSize,
      'u_Items_per_Layer': uItemsPerLayer,
      'u_Layers_per_Pallet': uLayersPerPallet,
      'PalletQty': uPalletQty,
      'UpdatedPercentage': updatedPercentage,
      'UpdatedPrice': updatedPrice,
      'NewPrice': newPrice,
      'isapproved': isapproved,
      'Marginpercentage': marginPercentage,
      'EPR': eprValue,
      'Category': category,
    };
  }
}
