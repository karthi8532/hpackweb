import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hpackweb/main.dart';
import 'package:hpackweb/models/pendingModel.dart';
import 'package:hpackweb/models/pricelistModel.dart';
import 'package:hpackweb/utils/sharedpref.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../models/customerModel.dart';
import '../../models/editpriceListmodel.dart';
import '../../service/apiservice.dart';
import '../../utils/apputils.dart';
import '../../utils/customsavebutton.dart';
import '../../widgets/assetimage.dart';

class ApprovalDetailPage extends StatefulWidget {
  final ApprovalDetail detail;
  final VoidCallback onClose;

  const ApprovalDetailPage({
    super.key,
    required this.detail,
    required this.onClose,
  });

  @override
  State<ApprovalDetailPage> createState() => _ApprovalDetailPageState();
}

class _ApprovalDetailPageState extends State<ApprovalDetailPage> {
  bool loading = false;
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController sapRemarksController = TextEditingController();

  final customerKey = GlobalKey<DropdownSearchState<CustomerModel>>();
  CustomerModel? selectedCustomer;
  List<EditPriceListModel> priceListData = [];
  PriceListDataGridSource? dataSource;
  final TextEditingController searchController = TextEditingController();
  String approveStatus = "";
  Map<String, dynamic>? selectedapproveItem;
  final approveKey = GlobalKey<DropdownSearchState<Map<String, dynamic>>>();

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

    searchController.addListener(_searchListener);
    getDocentryList();
  }

  void _searchListener() {
    // final query = searchController.text.toLowerCase();
    // dataSource?.updateSearchQuery(query);
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
        final List<dynamic> responseData = data['message']['details'];
        isApproved = result['AppovedStatus'] == "P" ? false : true;
        selectedapproveItem = approveList.firstWhere(
          (item) => item['id'] == result['Status'],
          orElse: () => {'id': 'P', 'name': 'Pending'},
        );
        selectedCustomer = CustomerModel(
          cardCode: result['CardCode'],
          cardName: result['CardName'],
          billingAddress: [],
          shippingAddress: [],
        );
        final List<EditPriceListModel> raw =
            responseData
                .map(
                  (e) => EditPriceListModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
        print(jsonEncode(raw.map((e) => e.toJson()).toList())); // ✅ Works?

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
                  (updated < (item.salesPrice ?? double.infinity)) ? 'Yes' : '';
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
        handleError("Unexpected status code: \${response.statusCode}");
      }
    } catch (e) {
      handleError("API error: $e");
    } finally {
      setState(() => loading = false);
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
                          buildTextField("Remarks", sapRemarksController, true),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child:
                            dataSource == null
                                ? const Center(child: Text("No data loaded"))
                                : SfDataGrid(
                                  source: dataSource!,
                                  allowEditing: true,
                                  allowSorting: true,
                                  allowFiltering: true,
                                  allowColumnsDragging: true,
                                  allowColumnsResizing: true,
                                  frozenColumnsCount:
                                      2, // freeze Item Code & Name
                                  columnWidthMode: ColumnWidthMode.auto,
                                  gridLinesVisibility: GridLinesVisibility.both,
                                  headerGridLinesVisibility:
                                      GridLinesVisibility.both,
                                  selectionMode: SelectionMode.single,
                                  navigationMode: GridNavigationMode.cell,
                                  editingGestureType: EditingGestureType.tap,

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
                                  onQueryRowHeight: (details) {
                                    if (details.rowIndex == 0)
                                      return 50; // header row

                                    final row =
                                        dataSource!.rows[details.rowIndex - 1];
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
                      const SizedBox(height: 16),
                      !isApproved
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomButton(
                                label: "Cancel",
                                onPressed: () {},
                                isPrimary: false,
                              ),
                              const SizedBox(width: 5),
                              CustomButton(
                                label: "Update",
                                onPressed: onUpdatePressed,
                                isPrimary: true,
                              ),
                            ],
                          )
                          : Container(),
                    ],
                  ),
                ),
      ),
    );
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
  bool isDialogShowing = false;
  List<DataGridRow> _rows = [];
  final List<EditPriceListModel> data;
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

  void handleSubmit(String value, EditPriceListModel model) async {
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
      model.marginPercentage =
          (updated - (model.evaluatedPrice ?? 0)) / updated;

      if (percent == 0) {
        model.isapproved = '';
        model.casePrice = updated;
        model.marginPercentage = 0;
        // model.updatedPrice = updated;
      } else if (updated > (model.evaluatedPrice ?? 0) &&
          updated < (model.salesPrice ?? double.infinity)) {
        model.isapproved = 'Yes';
      } else {
        model.isapproved = '';
      }
    }

    _buildRows();
    onUpdate();
  }
}
