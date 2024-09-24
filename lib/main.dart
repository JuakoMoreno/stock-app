/*import 'dart:math';
import 'package:flutter/material.dart';

/*import 'home_page.dart';
import 'stock_page.dart';*/


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Stock App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Button state variables
  bool isDownloadEnabled = true;
  bool isSendEnabled = false;
  bool isScanEnabled = false;

  // List to hold stock data rows
  List<DataRow> stockRows = [];

  // Content for each page
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _homePage();
      case 1:
        return _stockPage();
      default:
        return _homePage();
    }
  }

  Widget _homePage() {
    return Stack(
      children: <Widget>[
        // Download Button - Top Left
        Positioned(
          top: 20,
          left: 20,
          child: ElevatedButton(
            onPressed: isDownloadEnabled
              ? () {
                  setState(() {
                    isDownloadEnabled = false;
                    isScanEnabled = true;  // Enable "Scan Barcode" after download
                  });
                  Future.delayed(Duration(seconds: 60), () {
                    setState(() {
                      isDownloadEnabled = true; // Re-enable after 60 seconds
                    });
                  });
                }
              : null,
            child: Text('Download'),
          ),
        ),
        // Scan Barcode Button - Center and Bigger
        Center(
          child: ElevatedButton(
            onPressed: isScanEnabled
              ? () {
                  setState(() {
                    // Generate random values
                    String code = (Random().nextInt(900000) + 100000).toString(); // 6-digit random code
                    List<String> products = ['apples', 'cheetos', 'corona', 'soda', 'chips', 'milk', 'bread', 'candy'];
                    String productName = products[Random().nextInt(products.length)];
                    int amount = Random().nextInt(100) + 1; // Random amount between 1 and 100

                    // Add new row to stock data
                    stockRows.add(
                      DataRow(cells: [
                        DataCell(Text(code)),
                        DataCell(Text(productName)),
                        DataCell(Text(amount.toString())),
                      ]),
                    );
                    // Enable "Send" button when there are rows in the DataTable
                    if (stockRows.isNotEmpty) {
                      isSendEnabled = true;
                    }
                  });
                }
              : null, // Disable if download not pressed

            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              textStyle: TextStyle(fontSize: 24),
            ),
            child: Text('Scan Barcode'),
          ),
        ),
        // Send Button - Bottom Right
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: isSendEnabled && stockRows.isNotEmpty
              ? () {
                  int rowCount = stockRows.length; // Count how many rows are being cleaned
                  setState(() {
                    stockRows.clear(); // Clear the stock data
                    isSendEnabled = false; // Disable "Send" after clearing
                    isScanEnabled = true;  // Re-enable "Scan Barcode"
                  });
                  print('Cleaned $rowCount rows');
                }
              : null, // Disable if no rows or conditions not met

            child: Text('Send'),
          ),
        ),
      ],
    );
  }

  Widget _stockPage() {
    final columns = ['Code', 'Product Name', 'Amount'];
    final List<DataRow> rows = stockRows;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataTable(
                columns: columns
                    .map((column) => DataColumn(label: Text(column)))
                    .toList(),
                rows: rows,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, // Set AppBar background color to red
        centerTitle: true, // Center the title
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white, // Set AppBar text color to white
          ),
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                label: Text('Stock'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Display the selected page
          Expanded(
            child: _getSelectedPage(),
          ),
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'stock_page.dart';

//import 'package:sqflite/sqflite.dart'; // SQLite library
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI (only for desktop apps and testing)
  sqfliteFfiInit();

  // Set the database factory to FFI (required for non-mobile platforms)
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Stock App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;


  List<DataRow> stockRows = [];


  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage( stockRows: stockRows);
      case 1:
        return StockPage(stockRows: stockRows);
      default:
        return HomePage( stockRows: stockRows);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.home),       label: Text('Home')),
              NavigationRailDestination(icon: Icon(Icons.inventory),  label: Text('Stock')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                HomePage( stockRows: stockRows),
                StockPage(stockRows: stockRows),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
