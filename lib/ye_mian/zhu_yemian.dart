import 'package:flutter/material.dart';
import 'menzhen/menzhen_sanlan_yemian.dart';
import 'yaofang/yaofang_waike.dart';
import 'liliao/liliao_waike.dart';
import 'moban/moban_waike.dart';

class ZhuYeMian extends StatefulWidget {
  const ZhuYeMian({super.key});
  @override
  State<ZhuYeMian> createState() => _ZhuYeMianState();
}

class _ZhuYeMianState extends State<ZhuYeMian> {
  int _index = 0;
  final _tabs = const [
    MenZhenSanLanYeMian(),
    YaoFangWaiKe(),
    LiLiaoWaiKe(),
    MoBanWaiKe(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HIS')),
      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.local_hospital), label: '门诊'),
          NavigationDestination(icon: Icon(Icons.medication), label: '药房'),
          NavigationDestination(icon: Icon(Icons.healing), label: '理疗'),
          NavigationDestination(icon: Icon(Icons.note), label: '模板'),
        ],
      ),
    );
  }
}
