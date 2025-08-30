import 'package:flutter/material.dart';
import '../database_helper.dart';

class PrescriptionListPage extends StatefulWidget {
  final int patientId;

  PrescriptionListPage({required this.patientId});

  @override
  _PrescriptionListPageState createState() => _PrescriptionListPageState();
}

class _PrescriptionListPageState extends State<PrescriptionListPage> {
  List<Map<String, dynamic>> prescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  void _loadPrescriptions() async {
    var prescriptionsData = await getPrescriptions(widget.patientId);
    setState(() {
      prescriptions = prescriptionsData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patient Prescriptions")),
      body: ListView.builder(
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Prescription ${index + 1}"),
            subtitle: Text('Type: ${prescriptions[index]['type']}'),
          );
        },
      ),
    );
  }
}
