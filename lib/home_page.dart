import 'package:flutter/material.dart';
import 'dart:math';
import 'package:path/path.dart';   // Required for joining paths
import 'package:sqflite/sqflite.dart'; // SQLite library

class HomePage extends StatefulWidget {
  final List<DataRow> stockRows;

  const HomePage({Key? key, required this.stockRows}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDownloadEnabled = true;
  bool isScanEnabled = false;
  bool isSendEnabled = false; //<-- este faltaba
  bool isDeleting = false; // Flag to indicate deletion is in progress

  Map<String, String> productCodes = {};// Map to store product names and their corresponding unique codes
  Map<String, int> productAmounts = {}; // Map to store product names and their quantities

  List<String> columnNames = [];  // Store fetched column names

  @override
  void initState() {
    super.initState();
    // Fetch column names from the SQLite database when the widget is initialized
    getColumnNames('products').then((names) {
      setState(() {
        columnNames = names;  // Save the column names in the state
      });
      //print("Column Names: $columnNames");
    });
  }
  // Function to get column names from the SQLite database
  Future<List<String>> getColumnNames(String tableName) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'products.db'),  // Change to your database name
      onCreate: (db,version) async {
        /*return*/await db.execute(
          'CREATE TABLE products (code TEXT PRIMARY KEY, product_name TEXT NOT NULL, price REAL NOT NULL, current_stock INTEGER NOT NULL)',
        );
        await db.delete('products');
        /*await db.execute(
          'INSERT INTO products (code, product_name, price, current_stock) VALUES (136409, candy, 0, 18)',
        );
        await db.execute(
          'INSERT INTO products (code, product_name, price, current_stock) VALUES (467281, corona, 0, 4)',
        );
        await db.execute(
          'INSERT INTO products (code, product_name, price, current_stock) VALUES (124152, sugar, 0, 8)',
        );*/
      },
      version: 1,
    );   
    List<Map<String, dynamic>> result = await database.rawQuery('PRAGMA table_info($tableName)'); // Fetch table information using PRAGMA    
    //List<String> columnNames = result.map((row) => row['product_name'] as String).toList();               // Extract and return the column names
    List<String> columnNames = result.map((row) => row['name'] as String?).where((value) => value != null).map((value) => value!).toList();

    await database.close();  // Close the database after fetching
    return columnNames;
  }

  Future<List<String>> getQuery() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'products.db'),  // Change to your database name
      version: 1,
    );   
    
    List<Map<String, dynamic>> result = await database.rawQuery('SELECT * FROM products');
    List<String> queryResult = result.map((row) => row['product_name'] as String).toList(); // Extract and return the column names
    //List<String> queryResult = result.map((row) => row['product_name'] as String?).where((value) => value != null).map((value) => value!).toList();
    await database.close();  // Close the database after fetching
    //print("Select query: $queryResult");
    print("Select query: [${queryResult.join(',\n')}]");
    return queryResult;
  }

  Future<void> insertProduct(String? code, String? name, int amount) async {
    // Open the database
    final database = await openDatabase(
      join(await getDatabasesPath(), 'products.db'),
      version: 1,
    );

    // Create a map containing the values to be inserted
    Map<String, dynamic> product = {
      'code': code,
      'product_name': name,
      'price': 0,
      'current_stock': amount,
    };

    // Insert the product into the 'products' table
    await database.insert(
      'products',
      product,
      conflictAlgorithm: ConflictAlgorithm.replace, // Handle conflict by replacing the existing row
    );

    await database.close(); // Close the database after the insertion
  }

  Future<void> clearTable() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'products.db'),  // Change to your database name
      version: 1,

    );
    await database.delete('products');   
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Download Button
        Positioned(
          top: 20,
          left: 20,
          child: ElevatedButton(
            onPressed: isDownloadEnabled
              ? () async {
                  await clearTable();
                  List<String> names = await getColumnNames('products');
                  setState(() {
                    columnNames = names;

                    isDownloadEnabled = false;
                    isScanEnabled = true;
                  });
                  print("Column Names: $columnNames");
                  Future.delayed(Duration(seconds: 60), () { //60
                    setState(() {
                      isDownloadEnabled = true;
                    });
                  });
                }
              : null,
            child: const Text('Sincronizar'),
          ),
        ),
        // Scan Barcode Button
        Center(
          child: ElevatedButton(
            onPressed: isScanEnabled
                ? () {
                    setState(() {
                      List<String> products = ['apples', 'cheetos', 'corona', 'soda', 'chips', 'milk', 'bread', 'candy'];
                      String productName = products[Random().nextInt(products.length)];

                      // If product doesn't have a code yet, generate one
                      if (!productCodes.containsKey(productName)) {
                        String code = (Random().nextInt(1000000) + 1).toString();
                        productCodes[productName] = code;
                      }

                      // Update the amount of the product
                      int amount = Random().nextInt(20) + 1;
                      if (productAmounts.containsKey(productName)) {
                        productAmounts[productName] = productAmounts[productName]! + amount;
                      } else {
                        productAmounts[productName] = amount;
                      }

                      // Add or update the row in the stockRows
                      widget.stockRows.removeWhere((row) => row.cells[1].child.toString() == productName);
                      widget.stockRows.add(
                        DataRow(cells: [
                          DataCell(Text(productCodes[productName]!)), // Use the consistent product code
                          DataCell(Text(productName)),
                          DataCell(Text(productAmounts[productName]!.toString())), // Updated amount
                        ]),
                      );

                       isSendEnabled = true; // Enable the send button
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              textStyle: const TextStyle(fontSize: 24),
            ),
            child: const Text('Escanear codigo'),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: widget.stockRows.isNotEmpty && !isDeleting
                ? () {
                   int rowCount = widget.stockRows.length;
                    setState(() {
                      isDeleting = true; // Set deletion flag
                    });
                    print('Cleaned $rowCount rows');
                    _deleteRowsOneByOne(); // Trigger deletion of rows one by one
                  }
                : null,
            child: const Text('Enviar'),
            
          ),
        ),
      ],
    );
  }
  // Function to delete rows one by one
  void _deleteRowsOneByOne() async {
    while (widget.stockRows.isNotEmpty) {
      setState((){
        // Get the first row's data
        final row = widget.stockRows.first;
        
        final code = (row.cells[0].child as Text).data;
        final productName = (row.cells[1].child as Text).data;
        final amount = (row.cells[2].child as Text).data;
        
        /*
        final code = (row.cells[0].child as Text).data ?? '0';
        final productName = (row.cells[1].child as Text).data ?? '';
        final amount = int.tryParse((row.cells[2].child as Text).data ?? '0') ?? 0;
        */
        // Print mock SQL command
        print('INSERT INTO products VALUES ($code, $productName, $amount);');
        insertProduct(code,productName,5);

        // Remove the first row from the list
        widget.stockRows.removeAt(0);
      });
      
      // Wait for 1 second before deleting the next row (to simulate progressive deletion)
      await Future.delayed(Duration(seconds: 1));
    }

    List<String> queries = await getQuery();
    queries = [];
    //print("Select query: $queries");

    // After all rows are deleted, reset the deletion flag
    setState(() {
      isDeleting = false;
    });
  }
}
