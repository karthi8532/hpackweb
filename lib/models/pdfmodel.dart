class PdfListModel {
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

  PdfListModel({
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

  factory PdfListModel.fromJson(Map<String, dynamic> json) {
    // double caseprice = toDouble(json['CasePrice']);
    // double percent = toDouble(json['Percentage']);
    // double evaluatePrice = toDouble(json['EvaluatePrice']);
    // double updated = caseprice - (caseprice * percent / 100);
    // double newP = caseprice + updated;
    // double epr = toDouble(json['EPR']);
    // double marginPer =
    //     updated > 0 ? ((updated - evaluatePrice) / updated) * 100 : 0;

    return PdfListModel(
      uBrand: toStringSafe(json['Brand']),
      rowNo: toStringSafe(json['RowNo'] ?? "0"),
      stock: toDouble(json['Stock']),
      committed: toDouble(json['Committed']),
      order: toDouble(json['OnOrder']),
      salesPrice: toDouble(json['SalesPrice']),
      evaluatedPrice: toDouble(json['EvaluatePrice']),
      casePrice: toDouble(json['CasePrice']),
      eprValue: toDouble(json['EPR']),
      itemCode: toStringSafe(json['ItemCode']),
      itemName: toStringSafe(json['ItemName']),
      listNum: toStringSafe(json['PriceListNum']),
      listName: toStringSafe(json['PriceListName']),
      uCaseSize: toStringSafe(json['CaseQty']),
      uItemsPerLayer: toStringSafe(json['u_Items_per_Layer']),
      uLayersPerPallet: toStringSafe(json['u_Layers_per_Pallet']),
      uPalletQty: toDouble(json['PalletQty']),
      updatedPercentage: toDouble(json['UpdatedPercentage']),
      updatedPrice: toDouble(json['UpdatedPrice']),
      newPrice: toDouble(json['NewPrice']),
      isapproved: toStringSafe(json['isapproved']),
      marginPercentage: toDouble(json['Marginpercentage']),
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
