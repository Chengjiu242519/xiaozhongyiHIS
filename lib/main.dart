import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/outpatient_page.dart';
import 'pages/pharmacy_page.dart';
import 'pages/therapy_page.dart';
import 'pages/template_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  const chuangkouSize = Size(1280, 800);
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(size: chuangkouSize, center: true),
    () async {
      await windowManager.setResizable(false); // 禁止改变窗口大小
      await windowManager.setSize(chuangkouSize);
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(const ZhensuoApp());
}

class ZhensuoApp extends StatelessWidget {
  const ZhensuoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '诊所病历系统（UI）',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        visualDensity: VisualDensity.comfortable,
      ),
      home: const Shouye(),
    );
  }
}

class Shouye extends StatelessWidget {
  const Shouye({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('诊所病历系统（UI 版）'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '门诊'),
              Tab(text: '药房'),
              Tab(text: '理疗'),
              Tab(text: '模板'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [MenzhenPage(), YaofangPage(), LiliaoPage(), MobanPage()],
        ),
      ),
    );
  }
}
