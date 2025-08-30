import 'package:flutter/material.dart';

class ClinicPage extends StatefulWidget {
  @override
  _ClinicPageState createState() => _ClinicPageState();
}

class _ClinicPageState extends State<ClinicPage> {
  // 用来保存当前就诊记录的状态
  String _medicalRecord = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: '主诉'),
            onChanged: (value) {
              setState(() {
                _medicalRecord = value; // 更新当前记录
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              // 模拟提交病历
              print('病历提交：$_medicalRecord');
            },
            child: Text('提交病历'),
          ),
        ],
      ),
    );
  }
}
