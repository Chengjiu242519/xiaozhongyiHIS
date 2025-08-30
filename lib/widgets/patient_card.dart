import 'package:flutter/material.dart';
import '../models/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;

  PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(patient.name),
        subtitle: Text(patient.mobile),
        trailing: Icon(Icons.info),
        onTap: () {
          // 点击卡片可以跳转到该患者的详细信息页面
        },
      ),
    );
  }
}
