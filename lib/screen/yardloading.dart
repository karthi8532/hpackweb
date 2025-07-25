import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EditableDataGridScreen extends StatefulWidget {
  const EditableDataGridScreen({super.key});

  @override
  _EditableDataGridScreenState createState() => _EditableDataGridScreenState();
}

class Dealer {
  Dealer(this.productNo, this.dealerName, this.shipDate, this.country);

  int productNo;
  String dealerName;
  DateTime shipDate;
  String country;
}

class _EditableDataGridScreenState extends State<EditableDataGridScreen> {
  late DealerDataSource _dealerDataSource;
  final List<Dealer> _dealers = [
    Dealer(3634, 'Rooney', DateTime(2003, 8, 27), 'Austria'),
    Dealer(4523, 'Fitz', DateTime(2001, 7, 6), 'Argentina'),
    Dealer(1345, 'Mendoza', DateTime(2006, 5, 3), 'Canada'),
    Dealer(9475, 'Edwards', DateTime(2007, 8, 23), 'Brazil'),
    Dealer(1345, 'Irvine', DateTime(2005, 6, 13), 'Argentina'),
    Dealer(1803, 'Edwards', DateTime(2008, 5, 31), 'Canada'),
    Dealer(3634, 'Lane', DateTime(2001, 4, 30), 'Canada'),
  ];

  @override
  void initState() {
    _dealerDataSource = DealerDataSource(dealers: _dealers);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editable DataTable')),
      body: SfDataGrid(
        source: _dealerDataSource,
        allowEditing: true,
        selectionMode: SelectionMode.single,
        navigationMode: GridNavigationMode.cell,
        columnWidthMode: ColumnWidthMode.fill,
        columns: [
          GridColumn(columnName: 'productNo', label: buildHeader('Product No')),
          GridColumn(
            columnName: 'dealerName',
            label: buildHeader('Dealer Name'),
          ),
          GridColumn(
            columnName: 'shipDate',
            label: buildHeader('Shipped Date'),
          ),
          GridColumn(columnName: 'country', label: buildHeader('Ship Country')),
        ],
      ),
    );
  }

  Widget buildHeader(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class DealerDataSource extends DataGridSource {
  DealerDataSource({required List<Dealer> dealers}) {
    _dealers = dealers;
    buildDataGridRows();
  }

  late List<Dealer> _dealers;
  List<DataGridRow> _dataGridRows = [];

  void buildDataGridRows() {
    _dataGridRows =
        _dealers.map<DataGridRow>((dealer) {
          return DataGridRow(
            cells: [
              DataGridCell<int>(
                columnName: 'productNo',
                value: dealer.productNo,
              ),
              DataGridCell<String>(
                columnName: 'dealerName',
                value: dealer.dealerName,
              ),
              DataGridCell<String>(
                columnName: 'shipDate',
                value:
                    '${dealer.shipDate.month.toString().padLeft(2, '0')}/${dealer.shipDate.day.toString().padLeft(2, '0')}/${dealer.shipDate.year}',
              ),
              DataGridCell<String>(
                columnName: 'country',
                value: dealer.country,
              ),
            ],
          );
        }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8),
              child: Text(dataCell.value.toString()),
            );
          }).toList(),
    );
  }

  @override
  @override
  Widget buildEditWidget(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    final TextEditingController editingController = TextEditingController(
      text: dataGridRow.getCells()[rowColumnIndex.columnIndex].value.toString(),
    );

    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: editingController,
        autofocus: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onSubmitted: (_) {
          // Value will be read later in onCellSubmit
          submitCell(); // ✅ NO arguments
        },
      ),
    );
  }

  @override
  Future<void> onCellSubmit(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) async {
    final int rowIndex = _dataGridRows.indexOf(dataGridRow);
    final columnName = column.columnName;
    final newValue =
        dataGridRow.getCells()[rowColumnIndex.columnIndex].value.toString();

    Dealer dealer = _dealers[rowIndex];

    switch (columnName) {
      case 'productNo':
        dealer.productNo = int.tryParse(newValue) ?? dealer.productNo;
        break;
      case 'dealerName':
        dealer.dealerName = newValue;
        break;
      case 'shipDate':
        // Optional: convert MM/dd/yyyy string to DateTime if needed
        break;
      case 'country':
        dealer.country = newValue;
        break;
    }

    buildDataGridRows();
    notifyListeners();
  }
}
