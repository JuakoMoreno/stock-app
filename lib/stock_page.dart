import 'package:flutter/material.dart';

class StockPage extends StatelessWidget {
  final List<DataRow> stockRows;

  const StockPage({Key? key, required this.stockRows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = ['Code', 'Product Name', 'Amount'];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center (
                child: DataTable(
                  columns: columns
                    .map((column) => DataColumn(label: Text(column)))
                    .toList(),
                  rows: stockRows,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
