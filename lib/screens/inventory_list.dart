import 'package:flutter/material.dart';
import '../database_helper.dart';

class InventoryListPage extends StatefulWidget {
  @override
  _InventoryListPageState createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  List<Map<String, dynamic>> inventory = [];

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  void _loadInventory() async {
    var inventoryData =
        await getInventory(); // Assuming `getInventory()` fetches the inventory list
    setState(() {
      inventory = inventoryData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inventory Management")),
      body: ListView.builder(
        itemCount: inventory.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              title: Text(
                inventory[index]['name'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Stock: ${inventory[index]['stock']}'),
              trailing: inventory[index]['stock'] < 10
                  ? Icon(Icons.warning, color: Colors.red)
                  : null,
              onTap: () {
                // Handle item click (optional)
              },
            ),
          );
        },
      ),
    );
  }
}
