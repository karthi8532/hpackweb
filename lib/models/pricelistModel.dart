class PriceListModel {
  String? uBrand;
  String? rowNo;
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

  PriceListModel({
    this.uBrand,
    this.rowNo,
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

  factory PriceListModel.fromJson(Map<String, dynamic> json) {
    double caseprice = toDouble(json['CasePrice']);
    double percent = toDouble(json['Percentage']);
    double evaluatePrice = toDouble(json['EvaluatePrice']);
    double updated = caseprice - (caseprice * percent / 100);
    double newP = caseprice + updated;
    double epr = toDouble(json['EPR']);
    double marginPer =
        updated > 0 ? ((updated - evaluatePrice) / updated) * 100 : 0;

    return PriceListModel(
      uBrand: toStringSafe(json['Brand']),
      rowNo: toStringSafe(json['RowNo'] ?? "0"),
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

// class PriceListModel {
//   String? brand;
//   double? stock;
//   double? commited;
//   double? order;
//   double? salesPrice;
//   double? evaluatedPrice;
//   String? category;
//   String? itemCode;
//   String? itemName;
//   double? casePrice;
//   double updatedPercentage;
//   double? updatedPrice;
//   bool isGroupHeader;

//   PriceListModel({
//     this.brand,
//     this.stock,
//     this.commited,
//     this.order,
//     this.salesPrice,
//     this.evaluatedPrice,
//     this.category,
//     this.itemCode,
//     this.itemName,
//     this.casePrice,
//     this.updatedPercentage = 0,
//     this.updatedPrice,
//     this.isGroupHeader = false,
//   });

//   factory PriceListModel.fromJson(Map<String, dynamic> json) {
//     return PriceListModel(
//       brand: json['u_Brand'],
//       stock:
//           (json['stock'] != null)
//               ? double.tryParse(json['stock'].toString()) ?? 0.0
//               : 0.0,
//       commited:
//           (json['commited'] != null)
//               ? double.tryParse(json['commited'].toString()) ?? 0.0
//               : 0.0,
//       order:
//           (json['order'] != null)
//               ? double.tryParse(json['order'].toString()) ?? 0.0
//               : 0.0,
//       salesPrice:
//           (json['salesPrice'] != null)
//               ? double.tryParse(json['salesPrice'].toString()) ?? 0.0
//               : 0.0,
//       evaluatedPrice:
//           (json['evaluatedPrice'] != null)
//               ? double.tryParse(json['evaluatedPrice'].toString()) ?? 0.0
//               : 0.0,
//       category: (json['category'] ?? '').trim(),
//       itemCode: json['itemCode'],
//       itemName: json['itemName'],
//       casePrice: (json['casePrice'] ?? 0).toDouble(),
//     );
//   }
//   Map<String, dynamic> toJson() {
//     return {
//       'u_Brand': brand,
//       'stock': stock,
//       'commited': commited,
//       "itemCode": itemCode,
//       "itemName": itemName,
//       "casePrice": casePrice,
//       "updatedPercentage": updatedPercentage,
//       "updatedPrice": updatedPrice,
//       // Include other fields you need to send
//     };
//   }
// }
