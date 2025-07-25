import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  _PriceListScreenState createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  PriceListDataSource? _dataSource;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final body = {"salesEmployeeId": "43", "cardCode": "C101786"};

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.231:92/api/Price/GetPriceList'),
        body: jsonEncode(body),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        final dynamic responseData = jsonMap['response'];

        if (responseData is List) {
          final List<PriceListModel> items =
              responseData
                  .map<PriceListModel>((e) => PriceListModel.fromJson(e))
                  .toList();

          final groupedList = preprocessGroupedList(items);

          setState(() {
            _dataSource = PriceListDataSource(context, groupedList);
            _isLoading = false;
          });
        } else {
          print("Unexpected response format: $responseData");
          setState(() => _isLoading = false);
        }
      } else {
        print("Failed with status code: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grouped Price List')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _dataSource == null
              ? const Center(child: Text("No Data"))
              : SfDataGrid(
                allowColumnsResizing: true,
                source: _dataSource!,
                gridLinesVisibility: GridLinesVisibility.both,
                columnWidthMode: ColumnWidthMode.auto,
                headerGridLinesVisibility: GridLinesVisibility.both,
                selectionMode: SelectionMode.single,
                navigationMode: GridNavigationMode.cell,
                editingGestureType: EditingGestureType.tap,
                onQueryRowHeight: (RowHeightDetails details) {
                  final row = _dataSource!.rows[details.rowIndex];
                  final isHeader = row.getCells().any(
                    (cell) =>
                        cell.columnName == 'category  ' &&
                        cell.value.toString().startsWith('Header:'),
                  );
                  return isHeader
                      ? 80.0
                      : details.getIntrinsicRowHeight(details.rowIndex);
                },
                onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                  setState(() {
                    columnWidths[details.column.columnName] = details.width;
                  });
                  return true;
                },
                columns: [
                  GridColumn(
                    columnName: 'category',
                    minimumWidth: 150,
                    maximumWidth: 1000,
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Category                                   ',
                      ),
                    ),
                  ),
                  GridColumn(columnName: 'itemName', label: Text('Item Name')),
                  GridColumn(columnName: 'itemCode', label: Text('Item Code')),
                  GridColumn(
                    columnName: 'casePrice',
                    label: Text('Case Price'),
                  ),
                  GridColumn(
                    columnName: 'evaluatedPrice',
                    label: Text('Evaluated Price'),
                  ),
                  GridColumn(
                    columnName: 'updatedPrice',
                    label: Text('Updated Price'),
                  ),
                ],
              ),
    );
  }

  Map<String, double> columnWidths = {
    'category': double.nan,
    'itemName': double.nan,
    'itemCode': double.nan,
    'casePrice': double.nan,
    'evaluatedPrice': double.nan,
    'updatedPrice': double.nan,
  };
}

class PriceListModel {
  final String category;
  final String itemName;
  final String itemCode;
  final double casePrice;
  final double evaluatedPrice;
  final double updatedPrice;
  final bool isCategoryHeader;

  PriceListModel({
    required this.category,
    required this.itemName,
    required this.itemCode,
    required this.casePrice,
    required this.evaluatedPrice,
    required this.updatedPrice,
    this.isCategoryHeader = false,
  });

  factory PriceListModel.fromJson(Map<String, dynamic> json) {
    return PriceListModel(
      category: (json['category'] ?? '').trim(),
      itemName: json['itemName'] ?? '',
      itemCode: json['itemCode'] ?? '',
      casePrice: (json['casePrice'] ?? 0).toDouble(),
      evaluatedPrice: (json['evaluatedPrice'] ?? 0).toDouble(),
      updatedPrice: (json['updatedPrice'] ?? 0).toDouble(),
    );
  }
}

List<PriceListModel> preprocessGroupedList(List<PriceListModel> originalList) {
  Map<String, List<PriceListModel>> grouped = {};

  for (var item in originalList) {
    final key = item.category; // NO TRIM, NO REPLACE
    if (!grouped.containsKey(key)) {
      grouped[key] = [];
    }
    grouped[key]!.add(item);
  }

  List<PriceListModel> result = [];
  grouped.forEach((category, items) {
    result.add(
      PriceListModel(
        category: category,
        itemName: category,
        itemCode: '',
        casePrice: 0,
        evaluatedPrice: 0,
        updatedPrice: 0,
        isCategoryHeader: true,
      ),
    );
    result.addAll(items);
  });

  return result;
}

class PriceListDataSource extends DataGridSource {
  final BuildContext context;
  late List<DataGridRow> _rows;

  PriceListDataSource(this.context, List<PriceListModel> data) {
    _rows =
        data.map<DataGridRow>((item) {
          return DataGridRow(
            cells: [
              DataGridCell<String>(
                columnName: 'category',
                value: item.category,
              ),
              DataGridCell<String>(
                columnName: 'itemName',
                value: item.itemName,
              ),
              DataGridCell<String>(
                columnName: 'itemCode',
                value: item.itemCode,
              ),
              DataGridCell<double>(
                columnName: 'casePrice',
                value: item.casePrice,
              ),
              DataGridCell<double>(
                columnName: 'evaluatedPrice',
                value: item.evaluatedPrice,
              ),
              DataGridCell<double>(
                columnName: 'updatedPrice',
                value: item.updatedPrice,
              ),
              DataGridCell<bool>(
                columnName: 'isCategoryHeader',
                value: item.isCategoryHeader,
              ),
            ],
          );
        }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final isHeader =
        row
                .getCells()
                .firstWhere((e) => e.columnName == 'isCategoryHeader')
                .value
            as bool;

    if (isHeader) {
      final category =
          row
              .getCells()
              .firstWhere((e) => e.columnName == 'category')
              .value
              .toString();

      return DataGridRowAdapter(
        cells: [
          // First cell: Full-width container using Expanded
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade300,
            alignment: Alignment.centerLeft,
            child: Text(
              category,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          // Empty cells to match column count
          ...List.generate(5, (_) => const SizedBox.shrink()),
        ],
      );
    }

    // Normal data rows
    return DataGridRowAdapter(
      cells:
          row.getCells().sublist(0, 6).map((cell) {
            return Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text(cell.value.toString()),
            );
          }).toList(),
    );
  }
}

class CustomColumnSizer extends ColumnSizer {
  @override
  double computeCellWidth(
    GridColumn column,
    DataGridRow row,
    Object? cellValue,
    TextStyle textStyle,
  ) {
    if (column.columnName == 'category') {
      textStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
    }
    return super.computeCellWidth(column, row, cellValue, textStyle);
  }
}
