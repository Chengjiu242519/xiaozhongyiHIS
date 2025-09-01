import 'package:flutter/material.dart';
import 'app_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '门诊信息系统',
      theme: ThemeData(useMaterial3: true, fontFamily: 'YouYuan'),
      home: const AppShell(),
    );
  }
}
