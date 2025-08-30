import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/patient.dart';

class PatientListPage extends StatefulWidget {
  @override
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  List<Patient> patients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() async {
    var patientsData = await getPatients();
    setState(() {
      patients = patientsData
          .map(
            (patientData) => Patient(
              id: patientData['id'],
              name: patientData['name'],
              mobile: patientData['mobile'],
            ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patients")),
      body: ListView.builder(
        itemCount: patients.length,
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
                patients[index].name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(patients[index].mobile),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 点击患者，跳转到该患者的就诊记录页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VisitListPage(patientId: patients[index].id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
