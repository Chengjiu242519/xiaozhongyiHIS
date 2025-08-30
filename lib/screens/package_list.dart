import 'package:flutter/material.dart';
import '../database_helper.dart';

class PackageListPage extends StatefulWidget {
  @override
  _PackageListPageState createState() => _PackageListPageState();
}

class _PackageListPageState extends State<PackageListPage> {
  List<Map<String, dynamic>> packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  void _loadPackages() async {
    var packagesData =
        await getPackages(); // Assuming `getPackages()` fetches the package list
    setState(() {
      packages = packagesData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Package Management")),
      body: ListView.builder(
        itemCount: packages.length,
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
                packages[index]['name'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Price: \$${packages[index]['price']}'),
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
