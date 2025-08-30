import 'package:flutter/material.dart';
import '../database_helper.dart';

class TherapyListPage extends StatefulWidget {
  @override
  _TherapyListPageState createState() => _TherapyListPageState();
}

class _TherapyListPageState extends State<TherapyListPage> {
  List<Map<String, dynamic>> therapies = [];

  @override
  void initState() {
    super.initState();
    _loadTherapies();
  }

  void _loadTherapies() async {
    var therapiesData = await getTherapies(); // 获取理疗项目数据
    setState(() {
      therapies = therapiesData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Therapies")),
      body: ListView.builder(
        itemCount: therapies.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(therapies[index]['name']),
            subtitle: Text('Price: \$${therapies[index]['price']}'),
            onTap: () {
              // 显示理疗项目的详细信息
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Therapy Details'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${therapies[index]['name']}'),
                        Text('Price: \$${therapies[index]['price']}'),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
