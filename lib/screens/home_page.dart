import 'package:flutter/material.dart';
import 'ClinicPage.dart';
import 'PharmacyPage.dart';
import 'TemplatePage.dart';
import 'TherapyPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // 创建TabController来控制页面切换
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4个选项卡
  }

  @override
  void dispose() {
    _tabController.dispose(); // 在页面销毁时释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '门诊'),
            Tab(text: '药房'),
            Tab(text: '理疗'),
            Tab(text: '模板'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ClinicPage(), // 门诊页面
          PharmacyPage(), // 药房页面
          TherapyPage(), // 理疗页面
          TemplatePage(), // 模板页面
        ],
      ),
    );
  }
}
