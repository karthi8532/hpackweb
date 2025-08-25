import 'dart:convert';
import 'dart:ui';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hpackweb/models/customerModel.dart';
import 'package:hpackweb/models/pdfmodel.dart';
import 'package:hpackweb/models/pricelistModel.dart';
import 'package:hpackweb/screen/dashboard/dashboardpage.dart';
import 'package:hpackweb/service/apiservice.dart';
import 'package:hpackweb/utils/apputils.dart';
import 'package:hpackweb/utils/customsavebutton.dart';
import 'package:hpackweb/utils/sharedpref.dart';
import 'package:hpackweb/widgets/assetimage.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AddPriceListScreen extends StatefulWidget {
  const AddPriceListScreen({super.key});

  @override
  State<AddPriceListScreen> createState() => _AddPriceListScreenState();
}

class _AddPriceListScreenState extends State<AddPriceListScreen> {
  List<PriceListModel> priceListData = [];
  List<PdfListModel> pdfListData = [];
  PriceListDataGridSource? dataSource;
  List<PriceListModel> fullPriceListData = [];
  bool loading = false;
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController sapRemarksController = TextEditingController();
  final TextEditingController headerPercentageController =
      TextEditingController();

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
    //  widget.searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    //widget.searchController.removeListener(_onSearchChanged);
    // widget.searchController.dispose();
    toDateController.dispose();
    sapRemarksController.dispose();
    dataSource?.dispose();
    headerPercentageController.dispose();
    super.dispose();
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
                          children: [
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: headerPercentageController,
                                decoration: const InputDecoration(
                                  labelText: "Header %",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onFieldSubmitted: (value) {
                                  applyHeaderPercentage(value);
                                },
                                onEditingComplete: () {
                                  applyHeaderPercentage(
                                    headerPercentageController.text,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                applyHeaderPercentage(
                                  headerPercentageController.text,
                                );
                              },
                              child: const Text("Apply"),
                            ),
                          ],
                        ),
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
                                  allowFiltering: true,
                                  gridLinesVisibility: GridLinesVisibility.both,
                                  frozenColumnsCount: 4,
                                  selectionMode: SelectionMode.single,
                                  navigationMode: GridNavigationMode.cell,
                                  editingGestureType: EditingGestureType.tap,
                                  headerGridLinesVisibility:
                                      GridLinesVisibility.both,
                                  columns: [
                                    GridColumn(
                                      width: 150,
                                      columnName: 'Category',
                                      label: const Center(
                                        child: Text(
                                          'Category',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    GridColumn(
                                      columnName: 'Brand',
                                      label: const Center(
                                        child: Text(
                                          'Brand',
                                          style: TextStyle(fontSize: 14),
                                        ),
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
                  ],
                ),
      ),
    );
  }

  void applyHeaderPercentage(String value) {
    final percent = double.tryParse(value) ?? 0.0;

    for (var model in priceListData) {
      if (model.isGroupHeader) continue;
      if ((model.casePrice ?? 0) <= 0)
        continue; // ✅ skip rows with CasePrice = 0

      final casePrice = model.casePrice ?? 0.0;
      final updatedPrice = casePrice - ((casePrice * percent) / 100);

      // Validation
      if (updatedPrice < (model.evaluatedPrice ?? 0)) {
        model.isapproved = '';
        model.updatedPercentage = 0;
        model.updatedPrice = model.casePrice;
        model.marginPercentage = 0;
      } else {
        model.updatedPercentage = percent;
        model.updatedPrice = updatedPrice;
        model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;

        if (percent == 0 || (model.evaluatedPrice ?? 0) == 0) {
          model.isapproved = '';
          model.marginPercentage = 0;
        } else {
          model.marginPercentage =
              ((updatedPrice - (model.evaluatedPrice ?? 0)) / updatedPrice) *
              100;

          if (updatedPrice > (model.evaluatedPrice ?? 0) &&
              updatedPrice < (model.salesPrice ?? double.infinity)) {
            model.isapproved = 'Yes';
          } else {
            model.isapproved = '';
          }
        }
      }

      // ✅ Update the controllers in DataGridSource
      final itemCode = model.itemCode ?? 'row${priceListData.indexOf(model)}';
      if (dataSource!._controllers.containsKey(itemCode)) {
        dataSource!._controllers[itemCode]!.text =
            model.updatedPercentage?.toStringAsFixed(2) ?? '0.00';
      }
      if (dataSource!._updatedpricecontrollers.containsKey(itemCode)) {
        dataSource!._updatedpricecontrollers[itemCode]!.text =
            model.updatedPrice?.toStringAsFixed(2) ?? '0.00';
      }
    }

    // Refresh grid
    dataSource!._buildRows();
    dataSource!.notifyListeners();
    setState(() {});
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
      "BillingAddress": billingAddress,
      "ShippingAddress": shippingAddress,
      "PriceListNum": priceListId,
      "PriceListName": priceListName,
      "EffectiveDate": toDateController.text,
      "CreatedBy": Prefs.getEmpID(),
      "CreatedByName": Prefs.getName(),
      "CreatedDate": createdDate,
      "ApprovedByID": Prefs.getApprovedByUserId(),
      "ApprovedByName": Prefs.getApprovedByUserId(),
      "AppovedStatus": "P",
      "Remarks": sapRemarksController.text,
      "Status": "P",
      // "FromMail": Prefs.getFromMailID() ?? "",
      // "ToMail": Prefs.getToMailID() ?? "",
      "details":
          priceListData
              .where(
                (item) => !item.isGroupHeader && (item.updatedPrice ?? 0) > 0,
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
                  "MarginPercentage": item.marginPercentage ?? 0,
                  "ApprovalRequired": item.isapproved ?? '',
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
      "ApprovedByID": Prefs.getApprovedByUserId(),
      "ApprovedByName": Prefs.getApprovedByUserId(),
      "ApprovedStatus": "P",
      "EffectiveDate": toDateController.text,
      "Remarks": sapRemarksController.text,
      "Status": "P",
      "details":
          priceListData
              .where(
                (item) => !item.isGroupHeader && (item.updatedPrice ?? 0) > 0,
                //!item.isGroupHeader,
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
                  "MarginPercentage": item.marginPercentage ?? 0,
                  "ApprovalRequired": item.isapproved ?? '',
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
        claarlist();
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
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);

        if (jsonMap['status'].toString() == "true") {
          // print("Header Part$jsonMap");

          toDateController.text = jsonMap['message']['EffectiveDate'] ?? "";
          sapRemarksController.text = jsonMap['message']['Remarks'] ?? "";
          docEntry = jsonMap['message']['DocEntry'] ?? 0;

          final List<dynamic> responseData = jsonMap['message']['details'];
          claarlist();
          final List<PriceListModel> raw =
              responseData
                  .map(
                    (e) => PriceListModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList();

          // Apply percentage + approval color logic
          for (var item in raw) {
            if (item.updatedPercentage != null && item.updatedPercentage! > 0) {
              applyPercentageAndColorLogic(item);
            }
          }

          // Save raw list for export
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
          await loadData();
        }
      } else {
        print(
          "Invalid 'status' or 'message' in API. Fallback to getPriceList()",
        );
        await loadData();
      }
    } catch (e) {
      handleError("API error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void claarlist() {
    priceListData.clear();
    fullPriceListData.clear();
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

void applyPercentageAndColorLogic(PriceListModel model) {
  final percent = model.updatedPercentage ?? 0;
  final casePrice = model.casePrice ?? 0;
  final updated = casePrice - ((casePrice * percent) / 100);
  model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;
  if (updated < (model.evaluatedPrice ?? 0)) {
    model.isapproved = '';
    model.updatedPercentage = 0;
    model.updatedPrice = 0;
    model.marginPercentage = 0;
  } else {
    model.updatedPrice = updated;
    model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;

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

class PriceListDataGridSource extends DataGridSource {
  final List<PriceListModel> data;
  final VoidCallback onUpdate;
  final BuildContext context;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  final Map<String, TextEditingController> _updatedpricecontrollers = {};
  final Map<String, FocusNode> _updatedfocusNodes = {};

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

    _updatedpricecontrollers.putIfAbsent(itemCode, () {
      return TextEditingController(
        text:
            model.updatedPrice?.toStringAsFixed(2) ??
            (model.casePrice ?? 0).toStringAsFixed(2),
      );
    });
    _updatedfocusNodes.putIfAbsent(itemCode, () => FocusNode());

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
                      handlePriceOrPercentageChange(
                        value: controller.text,
                        model: model,
                        itemCode: itemCode,
                        isPercentageInput: true,
                      );
                    }
                  },
                  child: TextFormField(
                    controller: controller,
                    onTap:
                        () =>
                            controller.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: controller.value.text.length,
                            ),
                    focusNode: focusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      handlePriceOrPercentageChange(
                        value: controller.text,
                        model: model,
                        itemCode: itemCode,
                        isPercentageInput: true,
                      );
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

            if (cell.columnName == 'Updated Price' && !isHeader) {
              final controller = _updatedpricecontrollers[itemCode]!;
              final focusNode = _updatedfocusNodes[itemCode]!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      handlePriceOrPercentageChange(
                        value: controller.text,
                        model: model,
                        itemCode: itemCode,
                        isPercentageInput: false,
                      );
                    }
                  },
                  child: TextFormField(
                    controller: controller,
                    onTap:
                        () =>
                            controller.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: controller.value.text.length,
                            ),
                    focusNode: focusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      handlePriceOrPercentageChange(
                        value: controller.text,
                        model: model,
                        itemCode: itemCode,
                        isPercentageInput: false,
                      );
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

  void handlePriceOrPercentageChange({
    required String value,
    required PriceListModel model,
    required String itemCode,
    required bool
    isPercentageInput, // true if % field edited, false if price edited
  }) async {
    final casePrice = model.casePrice ?? 0.0;
    double updatedPrice = model.updatedPrice ?? casePrice;
    double percent = model.updatedPercentage ?? 0.0;

    if (isPercentageInput) {
      // user typed percentage → calculate price
      percent = double.tryParse(value) ?? 0.0;
      updatedPrice = casePrice - ((casePrice * percent) / 100);
    } else {
      // user typed price → calculate percentage
      updatedPrice = double.tryParse(value) ?? 0.0;
      percent =
          casePrice == 0 ? 0.0 : ((casePrice - updatedPrice) / casePrice) * 100;
    }

    // Validation
    if (updatedPrice < (model.evaluatedPrice ?? 0.0)) {
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

      // Reset controllers
      _controllers[itemCode]?.text = '0.00';
      _updatedpricecontrollers[itemCode]?.text = (model.casePrice ?? 0)
          .toStringAsFixed(2);
    } else {
      model.updatedPercentage = percent;
      model.updatedPrice = updatedPrice;
      model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;

      if (percent == 0 || (model.evaluatedPrice ?? 0) == 0) {
        model.isapproved = '';
        model.marginPercentage = 0;
      } else {
        model.marginPercentage =
            ((updatedPrice - (model.evaluatedPrice ?? 0)) / updatedPrice) * 100;

        if (updatedPrice > (model.evaluatedPrice ?? 0) &&
            updatedPrice < (model.salesPrice ?? double.infinity)) {
          model.isapproved = 'Yes';
        } else {
          model.isapproved = '';
        }
      }

      // ✅ Sync both controllers
      _controllers[itemCode]?.text = percent.toStringAsFixed(2);
      _updatedpricecontrollers[itemCode]?.text = updatedPrice.toStringAsFixed(
        2,
      );
    }

    _buildRows();
    onUpdate();
  }

  // void handleSubmit(String value, PriceListModel model, String itemCode) async {
  //   final percent = double.tryParse(value) ?? 0.0;
  //   model.updatedPercentage = percent;

  //   final casePrice = model.casePrice ?? 0.0;

  //   final updated = casePrice - ((casePrice * percent) / 100);

  //   model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;

  //   if (updated < (model.evaluatedPrice ?? 0.0)) {
  //     //Eval price
  //     if (isDialogShowing) return;
  //     isDialogShowing = true;

  //     await showDialog(
  //       context: context,
  //       builder:
  //           (_) => AlertDialog(
  //             title: const Text('Invalid Price'),
  //             content: const Text(
  //               'Updated Price cannot be lower than Cost Price.',
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: const Text('OK'),
  //               ),
  //             ],
  //           ),
  //     );

  //     isDialogShowing = false;
  //     model.isapproved = '';
  //     model.updatedPercentage = 0;
  //     model.updatedPrice = model.casePrice;
  //     model.marginPercentage = 0;
  //     _controllers[itemCode]?.text = '0.00';
  //   } else {
  //     model.updatedPrice = updated;
  //     model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;

  //     if (percent == 0 || model.evaluatedPrice == 0) {
  //       model.isapproved = '';
  //       model.marginPercentage = 0;
  //     } else {
  //       model.marginPercentage =
  //           ((updated - (model.evaluatedPrice ?? 0)) / updated) * 100;

  //       if (updated > (model.evaluatedPrice ?? 0) &&
  //           updated < (model.salesPrice ?? double.infinity)) {
  //         model.isapproved = 'Yes';
  //         model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;
  //       } else {
  //         model.isapproved = '';
  //         model.newPrice = (model.eprValue ?? 0) + model.updatedPrice!;
  //       }
  //     }

  //     _controllers[itemCode]?.text = percent.toStringAsFixed(2);
  //   }

  //   _buildRows();
  //   onUpdate();
  // }
}
