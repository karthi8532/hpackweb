import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hpackweb/models/pendingModel.dart';
import 'package:hpackweb/screen/approvaldetails/approvaldetails.dart';
import 'package:hpackweb/screen/kpicard.dart';
import 'package:hpackweb/service/apiservice.dart';
import 'package:hpackweb/utils/appcolor.dart';
import 'package:hpackweb/utils/apputils.dart';
import 'package:hpackweb/utils/sharedpref.dart';
import 'package:hpackweb/widgets/assetimage.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class ApprovalListPage extends StatefulWidget {
  final TextEditingController searchController;

  ApprovalListPage({super.key, required this.searchController, this.onRowTap});
  void Function(ApprovalDetail)? onRowTap;
  @override
  State<ApprovalListPage> createState() => _ApprovalListPageState();
}

class _ApprovalListPageState extends State<ApprovalListPage> {
  late ApprovalDataGridSource approvalDataSource;
  final DataGridController _dataGridController = DataGridController();
  ApprovalListMessage? approvalData;
  bool loading = true;
  List<ApprovalDetail> filteredApprovals = [];
  @override
  void initState() {
    super.initState();
    fetchApprovalList();
    widget.searchController.addListener(() {
      final query = widget.searchController.text.toLowerCase();
      setState(() {
        filteredApprovals =
            approvalData?.details.where((item) {
              return (item.cardCode.toLowerCase().contains(query) ?? false) ||
                  (item.cardName.toLowerCase().contains(query) ?? false) ||
                  (item.priceListName.toLowerCase().contains(query) ?? false) ||
                  (item.status.toLowerCase().contains(query) ?? false) ||
                  (item.remarks.toLowerCase().contains(query) ?? false) ||
                  (item.effectiveDate.toLowerCase().contains(query) ?? false) ||
                  (item.docentry.toString().contains(query) ?? false);
            }).toList() ??
            [];

        approvalDataSource = ApprovalDataGridSource(filteredApprovals);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body:
            loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // KPI cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          KpiCard(
                            title: 'Pending',
                            value: '${approvalData?.pending ?? 0}',
                            color: Colors.blue,
                          ),
                          KpiCard(
                            title: 'Approved',
                            value: '${approvalData?.approved ?? 0}',
                            color: Colors.green,
                          ),
                          KpiCard(
                            title: 'Rejected',
                            value: '${approvalData?.reject ?? 0}',
                            color: Colors.red,
                          ),
                          KpiCard(
                            title: 'Cancelled',
                            value: '${approvalData?.cancelled ?? 0}',
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Data table
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: SfDataGrid(
                            source: approvalDataSource,
                            controller: _dataGridController,
                            allowSorting: true,
                            allowMultiColumnSorting: true,
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            columnWidthMode: ColumnWidthMode.fill,
                            onCellTap: (DataGridCellTapDetails details) {
                              if (details.rowColumnIndex.rowIndex > 0) {
                                final rowIndex =
                                    details.rowColumnIndex.rowIndex - 1;
                                final tappedRow =
                                    approvalDataSource.rows[rowIndex];
                                final docEntry =
                                    tappedRow
                                        .getCells()
                                        .firstWhere(
                                          (cell) =>
                                              cell.columnName == 'docentry',
                                        )
                                        .value;
                                final detail = approvalDataSource
                                    .getApprovalByRow(rowIndex);

                                if (widget.onRowTap != null) {
                                  widget.onRowTap!(
                                    detail,
                                  ); // Notify Dashboard to show detail
                                }
                              }
                            },
                            columns: [
                              GridColumn(
                                columnName: 'docentry',
                                label: Center(
                                  child: Text(
                                    'Doc Entry',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'cardCode',
                                label: Center(
                                  child: Text(
                                    'Card Code',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'cardName',
                                label: Center(
                                  child: Text(
                                    'Customer Name',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'priceListName',
                                label: Center(
                                  child: Text(
                                    'Price List',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'effectiveDate',
                                label: Center(
                                  child: Text(
                                    'Effective On',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'remarks',
                                label: Center(
                                  child: Text(
                                    'Remarks',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'status',
                                label: Center(
                                  child: Text(
                                    'Status',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Future<void> fetchApprovalList() async {
    setState(() => loading = true);
    try {
      final response = await ApiService.getAllList({
        "ApprovedByID": Prefs.getEmpID(),
      });
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'].toString().toLowerCase() == "true") {
          final data = ApprovalListResponse.fromJson(jsonResponse);
          approvalData = data.message;
          approvalDataSource = ApprovalDataGridSource(approvalData!.details);
          filteredApprovals = approvalData!.details;
          approvalDataSource = ApprovalDataGridSource(filteredApprovals);
        } else {
          AppUtils.showSingleDialogPopup(
            context,
            jsonResponse['message'] ?? "Fetch failed",
            "Ok",
            exitpopup,
            AssetsImageWidget.errorimage,
          );
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        exitpopup,
        AssetsImageWidget.errorimage,
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void exitpopup() => AppUtils.pop(context);
}

// class ApprovalDataGridSource extends DataGridSource {
//   final List<ApprovalDetail> approvals;
//   List<DataGridRow> _rows = [];

//   ApprovalDataGridSource(this.approvals) {
//     _rows =
//         approvals.map((e) {
//           return DataGridRow(
//             cells: [
//               DataGridCell(
//                 columnName: 'docentry',
//                 value: e.docentry.toString(),
//               ),
//               DataGridCell(columnName: 'cardCode', value: e.cardCode),
//               DataGridCell(columnName: 'cardName', value: e.cardName),
//               DataGridCell(columnName: 'priceListName', value: e.priceListName),
//               DataGridCell(columnName: 'effectiveDate', value: e.effectiveDate),
//               DataGridCell(columnName: 'remarks', value: e.remarks),
//               DataGridCell(columnName: 'status', value: e.status),
//               DataGridCell(columnName: 'actions', value: null),
//             ],
//           );
//         }).toList();
//   }

//   @override
//   List<DataGridRow> get rows => _rows;

//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     final status =
//         row
//             .getCells()
//             .firstWhere((cell) => cell.columnName == 'status')
//             .value
//             .toString();
//     final index = _rows.indexOf(row);
//     final isEven = index % 2 == 0;

//     return DataGridRowAdapter(
//       color: (isEven ? Colors.grey[100] : Colors.white),
//       cells:
//           row.getCells().map((cell) {
//             if (cell.columnName == 'actions') {
//               return Center(
//                 child: ElevatedButton(
//                   onPressed: null,
//                   child: const Text("View"),
//                 ),
//               );
//             } else {
//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     cell.value.toString(),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               );
//             }
//           }).toList(),
//     );
//   }

//   Color? _getRowColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Colors.blue[50];
//       case 'approved':
//         return Colors.green[50];
//       case 'reject':
//         return Colors.red[50];
//       case 'cancelled':
//         return Colors.grey[200];
//       default:
//         return null;
//     }
//   }

//   ApprovalDetail getApprovalByRow(int index) {
//     return approvals[index];
//   }
// }
class ApprovalDataGridSource extends DataGridSource {
  final List<ApprovalDetail> approvals;
  List<DataGridRow> _rows = [];

  ApprovalDataGridSource(this.approvals) {
    _rows =
        approvals.map((e) {
          return DataGridRow(
            cells: [
              DataGridCell(
                columnName: 'docentry',
                value: e.docentry.toString(),
              ),
              DataGridCell(columnName: 'cardCode', value: e.cardCode),
              DataGridCell(columnName: 'cardName', value: e.cardName),
              DataGridCell(columnName: 'priceListName', value: e.priceListName),
              DataGridCell(columnName: 'effectiveDate', value: e.effectiveDate),
              DataGridCell(columnName: 'remarks', value: e.remarks),
              DataGridCell(columnName: 'status', value: e.status),
            ],
          );
        }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final status =
        row
            .getCells()
            .firstWhere((cell) => cell.columnName == 'status')
            .value
            .toString();
    final index = _rows.indexOf(row);
    final isEven = index % 2 == 0;

    return DataGridRowAdapter(
      color: isEven ? Colors.grey[100] : Colors.white,
      cells:
          row.getCells().map((cell) {
            if (cell.columnName == 'actions') {
              return Center(
                child: ElevatedButton(
                  onPressed: () {}, // Interaction is handled in `onCellTap`
                  child: const Text("View"),
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    cell.value.toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }
          }).toList(),
    );
  }

  ApprovalDetail getApprovalByRow(int index) => approvals[index];
}
