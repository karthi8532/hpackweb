import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hpackweb/models/pdfmodel.dart';
import 'package:hpackweb/models/pendingModel.dart';
import 'package:hpackweb/screen/dashboard/exportexcel.dart';
import 'package:hpackweb/screen/dashboard/pdfdownloader.dart';
import 'package:hpackweb/utils/sharedpref.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../models/customerModel.dart';
import '../../models/editpriceListmodel.dart';
import '../../service/apiservice.dart';
import '../../utils/apputils.dart';
import '../../widgets/assetimage.dart';

class ReportDetailPage extends StatefulWidget {
  final ApprovalDetail detail;
  final VoidCallback onClose;
  const ReportDetailPage({
    super.key,
    required this.detail,
    required this.onClose,
  });

  @override
  State<ReportDetailPage> createState() => _ApprovalDetailPageState();
}

class _ApprovalDetailPageState extends State<ReportDetailPage> {
  bool loading = false;
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController sapRemarksController = TextEditingController();
  TextEditingController approverRemarksController = TextEditingController();
  final customerKey = GlobalKey<DropdownSearchState<CustomerModel>>();
  CustomerModel? selectedCustomer;
  List<EditPriceListModel> priceListData = [];
  List<EditPriceListModel> fullPriceListData = [];
  PriceListDataGridSource? dataSource;
  String approveStatus = "";
  Map<String, dynamic>? selectedapproveItem;
  final approveKey = GlobalKey<DropdownSearchState<Map<String, dynamic>>>();
  List<PdfListModel> pdfListData = [];
  List<Map<String, dynamic>> approveList = [
    {'id': 'P', 'name': 'Pending'},
    {'id': 'A', 'name': 'Approved'},
    {'id': 'R', 'name': 'Rejected'},
    {'id': 'C', 'name': 'Cancelled'},
  ];
  bool isApproved = false;
  @override
  void initState() {
    super.initState();

    // widget.searchController.addListener(_searchListener);
    getDocentryList();
  }

  @override
  void dispose() {
    // widget.searchController.removeListener(_searchListener);
    // widget.searchController.dispose();
    toDateController.dispose();
    sapRemarksController.dispose();

    // // Dispose the data grid source
    dataSource?.dispose();
    super.dispose();
  }

  void getDocentryList() async {
    setState(() => loading = true);

    try {
      final response = await ApiService.getDetailByDocEntry(
        widget.detail.docentry,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final result = data['message'] as Map<String, dynamic>;
        print(result);
        print(result['EffectiveDate']);
        toDateController.text = result['EffectiveDate'] ?? "";
        sapRemarksController.text = result['Remarks'] ?? "";
        approverRemarksController.text = result['ApproverRemarks'] ?? "";
        final List<dynamic> responseData = data['message']['details'];
        isApproved = result['AppovedStatus'] == "P" ? false : true;
        selectedapproveItem = approveList.firstWhere(
          (item) => item['id'] == result['Status'],
          orElse: () => {'id': 'P', 'name': 'Pending'},
        );
        selectedCustomer = CustomerModel(
          cardCode: result['CardCode'],
          cardName: result['CardName'],
          billingAddress: parseRawAddress(result['BillingAddress']),
          shippingAddress: parseRawAddress(result['ShippingAddress']),
        );
        final List<EditPriceListModel> raw =
            responseData
                .map(
                  (e) => EditPriceListModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();

        for (var item in raw) {
          if (item.updatedPercentage != null && item.updatedPercentage! > 0) {
            applyPercentageAndColorLogic(item);
          }
        }
        fullPriceListData = List.from(raw);

        // Grouped list for UI display
        final grouped = withGroupedCategories(raw);

        // Set state once
        setState(() {
          priceListData = grouped;
          dataSource = PriceListDataGridSource(
            priceListData,
            context,
            onUpdate: () {
              setState(() {});
            },
          );
        });

        dataSource!._buildRows();
        dataSource!.notifyListeners();
      } else {
        handleError("Unexpected status code: \${response.statusCode}");
      }
    } catch (e) {
      handleError("API error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  List<AddressModel> parseRawAddress(String raw) {
    final parts = raw.split(',').map((e) => e.trim()).toList();

    return [
      AddressModel(
        address: parts.isNotEmpty ? parts[0] : '',
        address2: parts.length > 1 ? parts[1] : '',
        address3: parts.length > 2 ? parts[2] : '',
        zipCode: parts.length > 3 ? parts[3] : '',
        city: parts.length > 4 ? parts[4] : '',
        country: parts.length > 5 ? parts[5] : '',
      ),
    ];
  }

  void applyPercentageAndColorLogic(EditPriceListModel model) {
    final percent = model.updatedPercentage ?? 0;
    final casePrice = model.casePrice ?? 0;
    final updated = casePrice - ((casePrice * percent) / 100);

    if (updated < (model.evaluatedPrice ?? 0)) {
      model.isapproved = '';
      model.updatedPercentage = 0;
      model.updatedPrice = 0;
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
            updated != 0 && model.evaluatedPrice != null
                ? ((updated - model.evaluatedPrice!) / updated) * 100
                : 0;

        model.isapproved =
            (updated > (model.evaluatedPrice ?? 0) &&
                    updated < (model.salesPrice ?? double.infinity))
                ? 'Yes'
                : '';
      }
    }
  }

  List<EditPriceListModel> withGroupedCategories(
    List<EditPriceListModel> originalList,
  ) {
    final grouped = <String, List<EditPriceListModel>>{};

    for (var item in originalList) {
      final key =
          (item.category ?? 'Unknown').trim().toLowerCase(); // Normalize key
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final result = <EditPriceListModel>[];
    grouped.forEach((key, items) {
      final displayCategory = items.first.category?.trim() ?? 'Unknown';
      result.add(
        EditPriceListModel(category: displayCategory, isGroupHeader: true),
      );
      result.addAll(items);
    });

    return result;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Doc Entry : ${widget.detail.docentry}"),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: widget.onClose,
            ),
          ],
        ),
        body:
            loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            width: 405,
                            height: 40,
                            child: DropdownSearch<CustomerModel>(
                              enabled: false,
                              key: customerKey,
                              asyncItems:
                                  (String filter) =>
                                      ApiService.getpricecustomerlist(
                                        filter: filter,
                                      ),
                              itemAsString:
                                  (CustomerModel item) =>
                                      '${item.cardName ?? ''} (${item.cardCode ?? ''})',
                              selectedItem: selectedCustomer,
                              compareFn: (a, b) => a.cardCode == b.cardCode,
                              onChanged: (CustomerModel? selected) {
                                setState(() => selectedCustomer = selected);
                              },
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                itemBuilder:
                                    (ctx, item, isSelected) => ListTile(
                                      selected: isSelected,
                                      title: Text(
                                        item.cardName ?? '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      subtitle: Text(item.cardCode ?? ''),
                                      trailing:
                                          isSelected
                                              ? const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              )
                                              : null,
                                    ),
                              ),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Select Customer",
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          buildDateField(
                            "Effective Date",
                            toDateController,
                            context,
                          ),
                          SizedBox(width: 5),

                          SizedBox(
                            width: 200,
                            height: 40,
                            child: DropdownSearch<Map<String, dynamic>>(
                              key: approveKey,
                              enabled: false,
                              items: approveList,
                              itemAsString:
                                  (Map<String, dynamic>? item) =>
                                      item?['name'] ?? '',
                              onChanged: (value) {
                                setState(() {
                                  selectedapproveItem = value;
                                  approveStatus = value?['id'] ?? 'P';
                                });
                              },
                              selectedItem: selectedapproveItem,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  labelText: "Approval Status",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                interceptCallBacks: true,
                                itemBuilder: (ctx, item, isSelected) {
                                  return ListTile(
                                    selected: isSelected,
                                    title: Text(item['name'].toString()),
                                    onTap: () {
                                      approveKey.currentState?.popupValidate([
                                        item,
                                      ]);
                                      setState(() {
                                        approveStatus = item['id'].toString();
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          buildTextField(
                            "Remarks",
                            sapRemarksController,
                            false,
                          ),
                          SizedBox(width: 5),
                          buildTextField(
                            "Approver Remarks",
                            approverRemarksController,
                            false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          widget.detail.status == "A" ||
                                  widget.detail.status == "Approved"
                              ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () {
                                  handlePdfDownload(1);
                                },
                                child: Text(
                                  "Download Excel",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                              : Container(),
                          SizedBox(width: 10),
                          widget.detail.status == "A" ||
                                  widget.detail.status == "Approved"
                              ? ElevatedButton(
                                onPressed: () async {
                                  handlePdfDownload(2);
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
                                ? const Center(child: Text("No data loaded"))
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
                                    allowSorting: true,
                                    allowFiltering: true,
                                    allowColumnsDragging: true,
                                    allowColumnsResizing: true,
                                    frozenColumnsCount: 4,
                                    columnWidthMode: ColumnWidthMode.auto,
                                    gridLinesVisibility:
                                        GridLinesVisibility.both,
                                    headerGridLinesVisibility:
                                        GridLinesVisibility.both,
                                    selectionMode: SelectionMode.single,
                                    navigationMode: GridNavigationMode.cell,
                                    editingGestureType: EditingGestureType.tap,

                                    columns: [
                                      GridColumn(
                                        width: 150,
                                        columnName: 'Category',
                                        label: const Center(
                                          child: Text('Category'),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'Brand',
                                        label: const Center(
                                          child: Text('Brand'),
                                        ),
                                      ),
                                      GridColumn(
                                        width: 180,
                                        columnName: 'Item Code',
                                        label: const Center(
                                          child: Text(
                                            'Item Code',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        width: 160,
                                        columnName: 'Item Name',
                                        label: const Center(
                                          child: Text(
                                            'Item Name',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'Stock',
                                        label: const Center(
                                          child: Text(
                                            'Stock',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'Comitted',
                                        label: const Center(
                                          child: Text(
                                            'Comitted',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'Order',
                                        label: const Center(
                                          child: Text(
                                            'Order',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'SalesPrice',
                                        label: const Center(
                                          child: Text(
                                            'Preferred Price',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'Evaluate Price',
                                        label: const Center(
                                          child: Text(
                                            'Cost Price',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),

                                      GridColumn(
                                        columnName: 'Case Size',
                                        label: const Center(
                                          child: Text(
                                            'Case Size',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'Pallet Qty',
                                        label: const Center(
                                          child: Text(
                                            'Pallet Qty',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'Case Price',
                                        label: const Center(
                                          child: Text(
                                            'Current Price',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'Updated %',
                                        label: const Center(
                                          child: Text(
                                            'Updated %',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'Updated Price',
                                        label: const Center(
                                          child: Text(
                                            'Updated Price',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'EPR',
                                        label: const Center(
                                          child: Text(
                                            'EPR',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'New Price',
                                        label: const Center(
                                          child: Text(
                                            'New Price',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),

                                      GridColumn(
                                        columnName: 'Margin %',
                                        label: const Center(
                                          child: Text(
                                            'Margin %',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      GridColumn(
                                        columnName: 'Is Approval Required',
                                        label: const Center(
                                          child: Text(
                                            'Is Approval Required',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                    onQueryRowHeight: (details) {
                                      if (details.rowIndex == 0)
                                        return 50; // header row

                                      final row =
                                          dataSource!.rows[details.rowIndex -
                                              1];
                                      final categoryCell = row
                                          .getCells()
                                          .firstWhere(
                                            (c) => c.columnName == 'category',
                                            orElse:
                                                () => DataGridCell(
                                                  columnName: '',
                                                  value: '',
                                                ),
                                          );

                                      final isCategory =
                                          categoryCell.value
                                              .toString()
                                              .isNotEmpty;

                                      if (isCategory) {
                                        // Estimate text height based on font size and length
                                        final text =
                                            categoryCell.value.toString();
                                        final estimatedLines =
                                            (text.length / 40).ceil();
                                        return 32.0 +
                                            (estimatedLines *
                                                20.0); // Adjust as needed
                                      }

                                      return 50;
                                    },
                                  ),
                                ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
      ),
    );
  }

  Future<void> handlePdfDownload(int type) async {
    try {
      // Show loading spinner if needed
      setState(() => loading = true);

      final response = await ApiService.downloadApprovalPdf(
        selectedCustomer!.cardCode ?? "",
        widget.detail.docentry,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        //List<PdfListModel> priceList = [];
        pdfListData.clear();
        pdfListData =
            (json['message']['details'] as List)
                .map((e) => PdfListModel.fromJson(e))
                .toList();
        print(jsonEncode(pdfListData));
        if (type == 1) {
          //Excel
          ExcelExporter().exportPriceListWithHeader(
            data: pdfListData,
            customer: selectedCustomer,
          );
        } else {
          //PDF
          await PdfDownloadService.instance.downloadApprovedPdfWeb(
            customer: selectedCustomer,
            priceList: pdfListData,
          );
        }
        // print(jsonEncode(priceList));
      } else {
        AppUtils.showSingleDialogPopup(
          context,
          "Failed to download PDF: ${response.body}",
          "OK",
          () => AppUtils.pop(context),
          AssetsImageWidget.errorimage,
        );
        debugPrint("Failed to download PDF: ${response.body}");
      }
    } catch (e) {
      AppUtils.showSingleDialogPopup(
        context,
        "Failed to download PDF: ${e.toString()}",
        "OK",
        () => AppUtils.pop(context),
        AssetsImageWidget.errorimage,
      );
      debugPrint("Failed to download PDF: ${e.toString()}");
    } finally {
      setState(() => loading = false);
    }
  }

  void onUpdatePressed() async {
    if (selectedCustomer == null) {
      handleError("Please select a customer.");
      return;
    }

    if (toDateController.text.isEmpty) {
      handleError("Please select an effective date.");
      return;
    }

    setState(() => loading = true);

    try {
      var payload = {
        "DocEntry": widget.detail.docentry,
        "EffectiveDate": toDateController.text,
        "ApprovedByID": Prefs.getEmpID(),
        "ApprovedByName": Prefs.getName(),
        "ApprovedStatus": approveStatus,
        "Status": approveStatus,
        "Remarks": sapRemarksController.text,
        "details":
            priceListData
                .where((e) => !e.isGroupHeader)
                .map(
                  (e) => {
                    "RowNo": e.rowNo,
                    "Percentage": e.updatedPercentage,
                    "UpdatedPrice": e.updatedPrice,
                    "EPR": e.eprValue,
                    "NewPrice": e.newPrice,
                  },
                )
                .toList(),
      };

      final response = await ApiService.updateApproval(payload);

      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'].toString() == "true") {
          AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'],
            "OK",
            () => refreshpage(),
            AssetsImageWidget.successimage,
          );
        } else {
          AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'],
            "OK",
            () => stayonthepage(),
            AssetsImageWidget.successimage,
          );
        }
      } else {
        handleError("Update failed: ${response.body}");
      }
    } catch (e) {
      handleError("API Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    bool isEnabled,
  ) {
    return SizedBox(
      width: 200,
      child: TextFormField(
        enabled: false,
        readOnly: !isEnabled,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildDateField(
    String label,
    TextEditingController controller,
    BuildContext context,
  ) {
    return SizedBox(
      width: 200,
      child: TextField(
        enabled: false,
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: tomorrow,
            firstDate: tomorrow,
            lastDate: DateTime(2100),
          );
          if (date != null) {
            controller.text = DateFormat('dd/MM/yyyy').format(date);
          }
        },
      ),
    );
  }

  void refreshpage() {
    AppUtils.pop(context);
    widget.onClose();
  }

  void stayonthepage() {
    AppUtils.pop(context);
  }

  void onexitpopup() {
    AppUtils.pop(context);
    widget.onClose();
  }
}

class PriceListDataGridSource extends DataGridSource {
  final List<EditPriceListModel> data;
  final VoidCallback onUpdate;
  final BuildContext context;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  List<DataGridRow> _rows = [];
  bool isDialogShowing = false;

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
                value: e.isGroupHeader ? null : e.uBrand ?? '',
              ),
              DataGridCell<String>(
                columnName: 'Item Code',
                value: e.isGroupHeader ? null : e.itemCode ?? '',
              ),
              DataGridCell<String>(
                columnName: 'Item Name',
                value: e.isGroupHeader ? null : e.itemName ?? '',
              ),
              DataGridCell<String>(
                columnName: 'Stock',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.stock?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'Comitted',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.committed?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'Order',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.order?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'SalesPrice',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.salesPrice?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'Evaluate Price',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.evaluatedPrice?.toStringAsFixed(2) ?? '0.00'),
              ),

              DataGridCell<String>(
                columnName: 'Case Size',
                value: e.isGroupHeader ? null : e.uCaseSize ?? '',
              ),
              DataGridCell<String>(
                columnName: 'Pallet Qty',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.uPalletQty?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'Case Price',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.casePrice?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'Updated %',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.updatedPercentage?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'Updated Price',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.updatedPrice?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'EPR',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.eprValue?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'New Price',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.newPrice?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'Margin %',
                value:
                    e.isGroupHeader
                        ? null
                        : (e.marginPercentage?.toStringAsFixed(2) ?? '0.00'),
              ),
              DataGridCell<String>(
                columnName: 'Is Approval Required',
                value: e.isGroupHeader ? null : e.isapproved ?? '',
              ),
            ],
          );
        }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowIndex = _rows.indexOf(row);
    final model = data[rowIndex];
    final isHeader = row.getCells()[1].value == null;
    final isApproved = model.isapproved == 'Yes';
    final isCasePriceZero = model.casePrice == 0;
    final isUpdatePercentageZero = (model.updatedPercentage ?? 0) == 0;
    final isEvenRow = rowIndex % 2 == 0;
    final itemCode = model.itemCode ?? 'row$rowIndex';

    _controllers.putIfAbsent(itemCode, () {
      return TextEditingController(
        text: model.updatedPercentage?.toStringAsFixed(2) ?? '0.00',
      );
    });

    _focusNodes.putIfAbsent(itemCode, () => FocusNode());

    final bgColor =
        isCasePriceZero
            ? Colors.grey.shade200
            : (isApproved && !isUpdatePercentageZero
                ? Colors.green.shade100
                : (isEvenRow ? Colors.white : Colors.grey.shade50));

    return DataGridRowAdapter(
      color: isHeader ? Colors.grey[300] : bgColor,
      cells:
          row.getCells().asMap().entries.map((entry) {
            final index = entry.key;
            final cell = entry.value;

            if (cell.columnName == 'Updated %' && !isHeader) {
              final controller = _controllers[itemCode]!;
              final focusNode = _focusNodes[itemCode]!;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      handleSubmit(controller.text, model, itemCode);
                    }
                  },
                  child: TextFormField(
                    enabled: false,
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      handleSubmit(controller.text, model, itemCode);
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 0.5),
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
                  isHeader ? cell.value?.toString() ?? '' : '',
                  style: TextStyle(
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
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
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
    );
  }

  void handleSubmit(
    String value,
    EditPriceListModel model,
    String itemCode,
  ) async {
    final percent = double.tryParse(value) ?? 0.0;
    model.updatedPercentage = percent;

    final casePrice = model.casePrice ?? 0.0;
    final updated = casePrice - ((casePrice * percent) / 100);

    if (updated < (model.evaluatedPrice ?? 0.0)) {
      if (isDialogShowing) return;
      isDialogShowing = true;

      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Invalid Price'),
              content: const Text(
                'Updated Price cannot be lower than Cost Price.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );

      isDialogShowing = false;

      model.isapproved = '';
      model.updatedPercentage = 0;
      model.updatedPrice = model.casePrice;
      model.marginPercentage = 0;
      _controllers[itemCode]?.text = '0.00';
    } else {
      model.updatedPrice = updated;
      model.newPrice = (model.eprValue ?? 0) + updated;
      model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;
      if (percent == 0) {
        model.isapproved = '';
        model.marginPercentage = 0;
      } else {
        model.marginPercentage =
            ((updated - (model.evaluatedPrice ?? 0)) / updated) * 100;

        if (updated > (model.evaluatedPrice ?? 0) &&
            updated < (model.salesPrice ?? double.infinity)) {
          model.isapproved = 'Yes';
          model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;
        } else {
          model.isapproved = '';
          model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;
        }
      }

      _controllers[itemCode]?.text = percent.toStringAsFixed(2);
    }

    _buildRows();
    onUpdate();
  }
}
