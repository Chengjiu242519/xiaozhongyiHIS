import 'package:flutter/material.dart';
import '../database_helper.dart';

class VisitListPage extends StatefulWidget {
  final int patientId;

  VisitListPage({required this.patientId});

  @override
  _VisitListPageState createState() => _VisitListPageState();
}

class _VisitListPageState extends State<VisitListPage> {
  List<Map<String, dynamic>> visits = [];

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  void _loadVisits() async {
    var visitsData = await getVisits(widget.patientId); // 获取就诊记录
    setState(() {
      visits = visitsData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patient Visits")),
      body: ListView.builder(
        itemCount: visits.length,
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
                "Visit ${index + 1}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Doctor: ${visits[index]['doctor']}'),
              trailing: Icon(Icons.info_outline),
              onTap: () {
                // 显示就诊详细信息
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Visit Details'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chief Complaint: ${visits[index]['chief_complaint']}',
                          ),
                          Text('Diagnosis: ${visits[index]['diagnosis']}'),
                          Text('Doctor: ${visits[index]['doctor']}'),
                          Text('Visit Time: ${visits[index]['visit_time']}'),
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
            ),
          );
        },
      ),
    );
  }
}
