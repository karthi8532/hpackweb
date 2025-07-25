import 'dart:convert';
import 'dart:ui';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hpackweb/models/customerModel.dart';
import 'package:hpackweb/models/pricelistModel.dart';
import 'package:hpackweb/screen/dashboard/dashboardpage.dart';
import 'package:hpackweb/screen/dashboard/exportexcel.dart';
import 'package:hpackweb/screen/dashboard/pdfdownloader.dart';
import 'package:hpackweb/service/apiservice.dart';
import 'package:hpackweb/utils/apputils.dart';
import 'package:hpackweb/utils/customsavebutton.dart';
import 'package:hpackweb/utils/sharedpref.dart';
import 'package:hpackweb/widgets/assetimage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AddPriceListScreen extends StatefulWidget {
  final TextEditingController searchController;
  const AddPriceListScreen({super.key, required this.searchController});

  @override
  State<AddPriceListScreen> createState() => _AddPriceListScreenState();
}

class _AddPriceListScreenState extends State<AddPriceListScreen> {
  List<PriceListModel> priceListData = [];
  PriceListDataGridSource? dataSource;
  List<PriceListModel> fullPriceListData = [];
  bool loading = false;
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController sapRemarksController = TextEditingController();
  final customerKey = GlobalKey<DropdownSearchState<CustomerModel>>();
  CustomerModel? selectedCustomer;
  int docEntry = 0;
  String getcardCode = "";
  String status = "P";

  String priceListId = "";
  String priceListName = "";
  String billingAddress = "";
  String shippingAddress = "";
  @override
  void initState() {
    widget.searchController.addListener(_onSearchChanged);
    super.initState();
  }

  void _onSearchChanged() {
    final query = widget.searchController.text.toLowerCase();

    if (query.isEmpty) {
      priceListData = withGroupedCategories(fullPriceListData);
    } else {
      final filtered =
          fullPriceListData.where((item) {
            if (item.isGroupHeader) return false;
            return (item.itemCode?.toLowerCase().contains(query) ?? false) ||
                (item.itemName?.toLowerCase().contains(query) ?? false) ||
                (item.category?.toLowerCase().contains(query) ?? false) ||
                (item.uBrand?.toLowerCase().contains(query) ?? false);
          }).toList();

      priceListData = withGroupedCategories(filtered);
    }

    setState(() {
      dataSource = PriceListDataGridSource(
        priceListData,
        context,
        onUpdate: () {
          setState(() {});
        },
      );
    });
  }

  Future<void> loadData() async {
    try {
      setState(() {
        loading = true;
      });
      final body = {
        "salesEmployeeId": Prefs.getEmpID(),
        "cardCode": selectedCustomer?.cardCode ?? "",
      };

      final response = await ApiService.getpricelistdetails(body);

      setState(() => loading = false);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final List<dynamic> responseData = jsonMap['response'];

        priceListId = responseData[0]['PriceListNum'] ?? "";
        priceListName = responseData[0]['PriceListName'] ?? "";
        billingAddress = selectedCustomer!.billingFullAddress.toString();
        shippingAddress = selectedCustomer!.shippingFullAddress.toString();

        List<PriceListModel> raw =
            responseData
                .map((e) => PriceListModel.fromJson(e as Map<String, dynamic>))
                .toList();

        // fullPriceListData = List.from(priceListData);
        // priceListData = withGroupedCategories(raw);
        fullPriceListData = List.from(
          raw,
        ); // preserve full list before grouping
        priceListData = withGroupedCategories(raw);

        dataSource = PriceListDataGridSource(
          priceListData,
          context,
          onUpdate: () {
            setState(() {});
          },
        );
      } else {
        handleError("Unexpected status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => loading = false);
      handleError("API error: $e");
    }
  }

  void handleError(String message) {
    AppUtils.showSingleDialogPopup(
      context,
      message,
      "Ok",
      () => AppUtils.pop(context),
      AssetsImageWidget.errorimage,
    );
  }

  List<PriceListModel> withGroupedCategories(
    List<PriceListModel> originalList,
  ) {
    final grouped = <String, List<PriceListModel>>{};

    for (var item in originalList) {
      final key =
          (item.category ?? 'Unknown').trim().toLowerCase(); // Normalize key
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final result = <PriceListModel>[];
    grouped.forEach((key, items) {
      final displayCategory = items.first.category?.trim() ?? 'Unknown';
      result.add(
        PriceListModel(category: displayCategory, isGroupHeader: true),
      );
      result.addAll(items);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body:
            loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 550,
                          child: DropdownSearch<CustomerModel>(
                            key: customerKey,
                            asyncItems:
                                (filter) => ApiService.getpricecustomerlist(
                                  filter: filter,
                                ),
                            itemAsString:
                                (item) =>
                                    '${item.cardName ?? ''} (${item.cardCode ?? ''})',
                            selectedItem: selectedCustomer,
                            compareFn: (a, b) => a.cardCode == b.cardCode,
                            onChanged: (selected) {
                              setState(() {
                                selectedCustomer = selected;
                                getcardCode =
                                    selectedCustomer!.cardCode.toString();
                                if (selectedCustomer!.cardCode!.isEmpty) {
                                } else {
                                  checkcustomer();
                                }
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Select Customer",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildDateField("Effective Date", toDateController),
                        const SizedBox(width: 10),
                        _buildTextField("Remarks", sapRemarksController),
                        const SizedBox(width: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomButton(
                              label: "Cancel",
                              onPressed: () {},
                              isPrimary: false,
                            ),
                            const SizedBox(width: 8),
                            docEntry <= 0
                                ? CustomButton(
                                  isEnables: true,
                                  label: "Save",
                                  onPressed: _saved,
                                  isPrimary: true,
                                )
                                : CustomButton(
                                  isEnables: status == "P" ? true : false,
                                  label: "Update",
                                  onPressed: _update,
                                  isPrimary: true,
                                ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        docEntry > 0
                            ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () {
                                ExcelExporter().exportPriceListWithHeader(
                                  data: priceListData,
                                  customerName: selectedCustomer!.cardName!,
                                  shippingAddress:
                                      selectedCustomer!.shippingFullAddress,
                                  billingAddress:
                                      selectedCustomer!.billingFullAddress,
                                );
                              },
                              child: Text(
                                "Download Excel",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                            : Container(),
                        SizedBox(width: 10),
                        docEntry > 0
                            ? ElevatedButton(
                              onPressed: () async {
                                await PdfDownloadService.instance
                                    .downloadApprovedPdfWeb(
                                      customer: selectedCustomer,
                                      priceList: priceListData,
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: Text(
                                "Download PDF",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                            : Container(),
                        SizedBox(width: 10),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child:
                          dataSource == null
                              ? Center(child: Text(""))
                              : ScrollConfiguration(
                                behavior: ScrollConfiguration.of(
                                  context,
                                ).copyWith(
                                  scrollbars: true,
                                  dragDevices: {
                                    PointerDeviceKind.touch,
                                    PointerDeviceKind.mouse,
                                  },
                                ),
                                child: SfDataGrid(
                                  source: dataSource!,
                                  allowEditing: true,
                                  gridLinesVisibility: GridLinesVisibility.both,
                                  frozenColumnsCount: 2,
                                  columnWidthMode: ColumnWidthMode.auto,
                                  selectionMode: SelectionMode.single,
                                  navigationMode: GridNavigationMode.cell,
                                  editingGestureType: EditingGestureType.tap,
                                  headerGridLinesVisibility:
                                      GridLinesVisibility.both,
                                  columns: [
                                    GridColumn(
                                      columnName: 'Category',
                                      label: const Center(
                                        child: Text('Category'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Brand',
                                      label: const Center(child: Text('Brand')),
                                    ),

                                    GridColumn(
                                      columnName: 'Stock',
                                      label: const Center(child: Text('Stock')),
                                    ),
                                    GridColumn(
                                      columnName: 'Comitted',
                                      label: const Center(
                                        child: Text('Comitted'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Order',
                                      label: const Center(child: Text('Order')),
                                    ),
                                    GridColumn(
                                      columnName: 'SalesPrice',
                                      label: const Center(
                                        child: Text('Sales Price'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Evaluate Price',
                                      label: const Center(
                                        child: Text('Evaluate Price'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Item Code',
                                      label: const Center(
                                        child: Text('Item Code'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Item Name',
                                      label: const Center(
                                        child: Text('Item Name'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Case Size',
                                      label: const Center(
                                        child: Text('Case Size'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Pallet Qty',
                                      label: const Center(
                                        child: Text('Pallet Qty'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Case Price',
                                      label: const Center(
                                        child: Text('Case Price'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Updated %',
                                      label: const Center(
                                        child: Text('Updated %'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Updated Price',
                                      label: const Center(
                                        child: Text('Updated Price'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'New Price',
                                      label: const Center(
                                        child: Text('New Price'),
                                      ),
                                    ),

                                    GridColumn(
                                      columnName: 'Margin %',
                                      label: const Center(
                                        child: Text('Margin %'),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Is Approval Required',
                                      label: const Center(
                                        child: Text('Is Approval Required'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
      ),
    );
  }

  Future<void> _saved() async {
    if (selectedCustomer == null) {
      AppUtils.showSingleDialogPopup(
        context,
        "Please select a customer",
        "OK",
        onexitpopup,
        null,
      );
      return;
    }
    if (toDateController.text.isEmpty) {
      AppUtils.showSingleDialogPopup(
        context,
        "Please select a Effective Date",
        "OK",
        onexitpopup,
        null,
      );
      return;
    }

    setState(() {
      loading = true;
    });
    final String createdDate = DateTime.now().toIso8601String();
    final header = {
      "CardCode": selectedCustomer!.cardCode,
      "CardName": selectedCustomer!.cardName,
      "ShippingAddress": shippingAddress,
      "BillingAddress": billingAddress,
      "PriceListNum": priceListId,
      "PriceListName": priceListName,
      "EffectiveDate": toDateController.text,
      "CreatedBy": Prefs.getEmpID(),
      "CreatedByName": Prefs.getName(),
      "CreatedDate": createdDate,
      "ApprovedByID": Prefs.getApprovedBy(),
      "ApprovedByName": Prefs.getApprovedByUserId(),
      "AppovedStatus": "P",
      "Status": "P",
      "details":
          priceListData
              .where(
                (item) =>
                    !item.isGroupHeader && (item.isapproved ?? "") == "Yes",
              )
              .map(
                (item) => {
                  "Category": item.category,
                  "Brand": item.uBrand,
                  "Stock": item.stock,
                  "Committed": item.committed,
                  "OnOrder": item.order,
                  "EvaluatePrice": item.evaluatedPrice,
                  "SalesPrice": item.salesPrice,
                  "ItemCode": item.itemCode,
                  "ItemName": item.itemName ?? "",
                  "CardCode": selectedCustomer?.cardCode ?? "",
                  "CardName": selectedCustomer?.cardName ?? "",
                  "PriceListNum": item.listNum ?? "",
                  "PriceListName": item.listName ?? "",
                  "Currency": "AED", // or item.currency ?? ""
                  "CaseQty": item.uCaseSize,
                  "PalletQty": item.uPalletQty,
                  "CasePrice": item.casePrice ?? 0,
                  "Percentage": item.updatedPercentage ?? 0,
                  "UpdatedPrice": item.updatedPrice ?? 0,
                  "EPR": item.eprValue,
                  "NewPrice": item.newPrice,
                },
              )
              .toList(),
    };

    try {
      final response = await ApiService.postPriceUpdate(header);
      setState(() {
        loading = false;
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonDecode(response.body)['status'].toString() == "true") {
          AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'].toString(),
            "OK",
            refreshpage,
            AssetsImageWidget.successimage,
          );
        } else {
          final error = jsonDecode(response.body)['message'] ?? "Unknown error";
          handleError("Server error: $error");
        }
      } else {
        final error = jsonDecode(response.body)['message'] ?? "Unknown error";
        handleError("Server error: $error");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      handleError("Failed to send data: $e");
    }
  }

  Future<void> _update() async {
    if (selectedCustomer == null) {
      AppUtils.showSingleDialogPopup(
        context,
        "Please select a customer",
        "OK",
        onexitpopup,
        null,
      );
      return;
    }
    if (toDateController.text.isEmpty) {
      AppUtils.showSingleDialogPopup(
        context,
        "Please select a Effective Date",
        "OK",
        onexitpopup,
        null,
      );
      return;
    }

    setState(() {
      loading = true;
    });
    final String createdDate = DateTime.now().toIso8601String();
    final header = {
      "DocEntry": docEntry,
      "ApprovedByID": Prefs.getApprovedBy(),
      "ApprovedByName": Prefs.getApprovedByUserId(),
      "ApprovedStatus": "P",
      "EffectiveDate": toDateController.text,
      "Remarks": sapRemarksController.text,
      "Status": "P",
      "details":
          priceListData
              .where(
                (item) =>
                    !item.isGroupHeader && (item.isapproved ?? "") == "Yes",
              )
              .map(
                (item) => {
                  //"Category": item.category,
                  "RowNo": item.rowNo,
                  // "Brand": item.uBrand,
                  // "Stock": item.stock,
                  // "Committed": item.committed,
                  // "OnOrder": item.order,
                  // "EvaluatePrice": item.evaluatedPrice,
                  // "SalesPrice": item.salesPrice,
                  // "ItemCode": item.itemCode,
                  // "ItemName": item.itemName ?? "",
                  // "CardCode": selectedCustomer?.cardCode ?? "",
                  // "CardName": selectedCustomer?.cardName ?? "",
                  // "PriceListNum": item.listNum ?? "",
                  // "PriceListName": item.listName ?? "",
                  // "Currency": "AED", // or item.currency ?? ""
                  // "CaseQty": item.uCaseSize,
                  // "PalletQty": item.uPalletQty,
                  // "CasePrice": item.casePrice ?? 0,
                  "Percentage": item.updatedPercentage ?? 0,
                  "UpdatedPrice": item.updatedPrice ?? 0,
                  "EPR": item.eprValue,
                  "NewPrice": item.newPrice,
                },
              )
              .toList(),
    };

    try {
      final response = await ApiService.priceUpdatePendingOrApproved(header);
      setState(() {
        loading = false;
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonDecode(response.body)['status'].toString() == "true") {
          AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'].toString(),
            "OK",
            refreshpage,
            AssetsImageWidget.successimage,
          );
        } else {
          final error = jsonDecode(response.body)['message'] ?? "Unknown error";
          handleError("Server error: $error");
        }
      } else {
        final error = jsonDecode(response.body)['message'] ?? "Unknown error";
        handleError("Server error: $error");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      handleError("Failed to send data: $e");
    }
  }

  void onexitpopup() {
    AppUtils.pop(context);
  }

  void refreshpage() {
    AppUtils.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardPage()),
    );
  }

  void checkcustomer() async {
    if (selectedCustomer == null || selectedCustomer!.cardCode!.isEmpty) {
      handleError("Customer not selected");
      return;
    }

    setState(() => loading = true);

    try {
      final response = await ApiService.checkCustmerexists(
        selectedCustomer!.cardCode.toString(),
      );

      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'].toString() == "true") {
          final Map<String, dynamic> jsonMap = jsonDecode(response.body);

          print("Header Part$jsonMap");
          toDateController.text = jsonMap['message']['EffectiveDate'] ?? "";
          sapRemarksController.text = jsonMap['message']['Remarks'] ?? "";
          docEntry = jsonMap['message']['DocEntry'] ?? 0;
          final List<dynamic> responseData = jsonMap['message']['details'];

          final List<PriceListModel> raw =
              responseData
                  .map(
                    (e) => PriceListModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList();
          //print(jsonEncode(raw.map((e) => e.toJson()).toList())); // ✅ Works?
          fullPriceListData = List.from(
            raw,
          ); // preserve full list before grouping
          priceListData = withGroupedCategories(raw);
          for (var item in raw) {
            if (item.updatedPercentage != null && item.updatedPercentage! > 0) {
              final updated =
                  item.casePrice! +
                  ((item.updatedPercentage ?? 0) * item.casePrice!) / 100;

              item.updatedPrice = updated;
              item.newPrice = (item.eprValue ?? 0) + updated;

              if (updated < (item.evaluatedPrice ?? 0)) {
                item.isapproved = '';
                item.marginPercentage = 0;
              } else {
                item.marginPercentage =
                    (updated - (item.evaluatedPrice ?? 0)) / updated;
                item.isapproved =
                    (updated < (item.salesPrice ?? double.infinity))
                        ? 'Yes'
                        : '';
              }
            }
          }
          setState(() {
            priceListData = withGroupedCategories(raw);
            dataSource = PriceListDataGridSource(
              priceListData,
              context,
              onUpdate: () {
                setState(() {});
              },
            );
          });
        } else {
          loadData();
        }
      } else {
        print(
          "Invalid 'status' or 'message' in API. Fallback to getPriceList()",
        );
        loadData();
      }
    } catch (e) {
      handleError("API error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  PriceListModel? getExistingItem(String itemCode) {
    try {
      return priceListData.firstWhere(
        (oldItem) => oldItem.itemCode == itemCode,
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return SizedBox(
      width: 200,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            controller.text = DateFormat('dd/MM/yyyy').format(date);
          }
        },
      ),
    );
  }
}

class PriceListDataGridSource extends DataGridSource {
  bool isDialogShowing = false;
  List<DataGridRow> _rows = [];
  final List<PriceListModel> data;
  final VoidCallback onUpdate;
  BuildContext context;
  PriceListDataGridSource(this.data, this.context, {required this.onUpdate}) {
    _buildRows();
  }

  void _buildRows() {
    _rows =
        data.map((e) {
          return DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'Category', value: e.category),
              DataGridCell<String>(
                columnName: 'Brand',
                value: e.isGroupHeader ? null : e.uBrand,
              ),
              DataGridCell<String>(
                columnName: 'Stock',
                value: e.isGroupHeader ? null : e.stock!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'Comitted',
                value: e.isGroupHeader ? null : e.committed!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'Order',
                value: e.isGroupHeader ? null : e.order!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'SalesPrice',
                value:
                    e.isGroupHeader ? null : e.salesPrice!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'Evaluate Price',
                value:
                    e.isGroupHeader
                        ? null
                        : e.evaluatedPrice!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'Item Code',
                value: e.isGroupHeader ? null : e.itemCode,
              ),
              DataGridCell<String>(
                columnName: 'Item Name',
                value: e.isGroupHeader ? null : e.itemName,
              ),
              DataGridCell<String>(
                columnName: 'Case Size',
                value: e.isGroupHeader ? null : e.uCaseSize,
              ),
              DataGridCell<String>(
                columnName: 'Pallet Qty',
                value:
                    e.isGroupHeader ? null : e.uPalletQty!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'Case Price',
                value: e.isGroupHeader ? null : e.casePrice!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'Updated %',
                value:
                    e.isGroupHeader
                        ? null
                        : e.updatedPercentage!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'Updated Price',
                value:
                    e.isGroupHeader ? null : e.updatedPrice!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'New Price',
                value:
                    e.isGroupHeader ? null : e.updatedPrice!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'Margin %',
                value:
                    e.isGroupHeader
                        ? null
                        : e.marginPercentage!.toStringAsFixed(2),
              ),
              DataGridCell<String>(
                columnName: 'Is Approval Required',
                value: e.isGroupHeader ? null : e.isapproved.toString(),
              ),
            ],
          );
        }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final isHeader = row.getCells()[1].value == null;
    final int rowIndex = _rows.indexOf(row);
    final model = data[rowIndex];
    final Map<String, TextEditingController> controllers = {};
    final bool isApproved = model.isapproved == 'Yes';
    final bool isCasePriceZero = model.casePrice == 0;
    final bool isUpdatePercentageZero = model.updatedPercentage == 0;
    final bool isEvenRow = rowIndex % 2 == 0;
    dynamic editedValue;
    TextEditingController getController(String itemCode, String initialValue) {
      if (!controllers.containsKey(itemCode)) {
        controllers[itemCode] = TextEditingController(text: initialValue);
      }
      return controllers[itemCode]!;
    }

    final FocusNode focusNode = FocusNode();
    final Color backgroundColor =
        isCasePriceZero
            ? Colors.grey.shade200
            : (isApproved && !isUpdatePercentageZero
                ? Colors.green.shade100
                : (isEvenRow ? Colors.white : Colors.grey.shade50));
    return DataGridRowAdapter(
      color: isHeader ? Colors.grey[300] : backgroundColor,

      cells:
          row.getCells().asMap().entries.map((entry) {
            final index = entry.key;
            final cell = entry.value;
            final controller = TextEditingController(
              text: model.updatedPercentage?.toString() ?? '',
            );
            if (cell.columnName == 'Updated %' && !isHeader) {
              // Updated % column and not header row
              final model = data[_rows.indexOf(row)];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: RawKeyboardListener(
                  focusNode: focusNode,
                  onKey: (RawKeyEvent event) {
                    if (event is RawKeyDownEvent) {
                      // Enter key: submit
                      if (event.logicalKey == LogicalKeyboardKey.enter ||
                          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                        handleSubmit(controller.text, model);
                      }

                      // Tab key: move to next focus
                      if (event.logicalKey == LogicalKeyboardKey.tab) {
                        FocusScope.of(context).nextFocus();
                      }
                    }
                  },
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        editedValue = controller.text;
                        handleSubmit(editedValue, model);
                      }
                    },
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            if (cell.columnName == 'Category') {
              return Container(
                width: 800,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  isHeader ? cell.value?.toString() ?? '' : "",
                  style: TextStyle(
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                    fontSize: isHeader ? 14 : 14,
                  ),
                ),
              );
            }
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                cell.value?.toString() ?? '',
                style: TextStyle(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                  fontSize: isHeader ? 16 : 14,
                ),
              ),
            );
          }).toList(),
    );
  }

  void handleSubmit(String value, PriceListModel model) async {
    final percent = double.tryParse(value.toString()) ?? 0.0;
    model.updatedPercentage = percent;

    final double casePrice = model.casePrice ?? 0;
    final double updated = casePrice - ((casePrice * percent) / 100);

    if (updated < (model.evaluatedPrice ?? 0)) {
      if (isDialogShowing) return;

      isDialogShowing = true;
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Invalid Price'),
              content: Text('Updated Price cannot be lower than Cost Price.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
      );
      isDialogShowing = false;

      model.isapproved = '';
      model.updatedPercentage = 0;
      model.marginPercentage = 0;
    } else {
      model.updatedPrice = updated;
      model.newPrice = (model.eprValue ?? 0) + updated;

      if (percent == 0) {
        model.isapproved = '';
        model.casePrice = updated;
        model.marginPercentage = 0;
      } else {
        model.marginPercentage =
            (updated - (model.evaluatedPrice ?? 0)) / updated;

        if (updated > (model.evaluatedPrice ?? 0) &&
            updated < (model.salesPrice ?? double.infinity)) {
          model.isapproved = 'Yes';
        } else {
          model.isapproved = '';
        }
      }
    }

    _buildRows();
    onUpdate();
  }
}
