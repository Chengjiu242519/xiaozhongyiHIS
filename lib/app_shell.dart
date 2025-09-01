import 'package:flutter/material.dart';
import 'pages/menzhen_page.dart';
import 'pages/yaofang_page.dart';
import 'pages/liliao_page.dart';
import 'pages/moban_page.dart';

/// 顶部带图标 TabBar 的应用外壳
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          title: Row(
            children: const [
              Icon(Icons.local_hospital_outlined),
              SizedBox(width: 8),
              Text('门诊信息系统'),
            ],
          ),
          centerTitle: false,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.medical_services_outlined), text: '门诊'),
              Tab(icon: Icon(Icons.local_pharmacy_outlined), text: '药房'),
              Tab(icon: Icon(Icons.healing_outlined), text: '理疗'),
              Tab(icon: Icon(Icons.view_list_outlined), text: '模板'),
            ],
          ),
        ),
        body: const TabBarView(
          // 用 KeepAlive 包一层，切换 Tab 不丢滚动/表单状态
          children: [
            KeepAlive(child: MenZhenPage()),
            KeepAlive(child: YaofangPage()),
            KeepAlive(child: LiLiaoPage()),
            KeepAlive(child: MobanPage()),
          ],
        ),
      ),
    );
  }
}

/// 保活容器，维持子组件的状态（滚动位置、表单等）
class KeepAlive extends StatefulWidget {
  const KeepAlive({super.key, required this.child});
  final Widget child;

  @override
  State<KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
