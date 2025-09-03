import 'package:flutter/material.dart';
import '../../shuju_moban/huanzhe.dart';
import '../../shuju_moban/lishi_jiuzhen_xiang.dart';

class LiShiLan extends StatelessWidget {
  final Huanzhe? huanzhe;
  final List<LiShiJiuZhenXiang> lishi;
  const LiShiLan({super.key, required this.huanzhe, required this.lishi});

  @override
  Widget build(BuildContext context) {
    if (huanzhe == null) return const Center(child: Text('未选择患者'));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('历史就诊：${huanzhe!.name}'),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: lishi.length,
            itemBuilder: (ctx, i) {
              final e = lishi[i];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(e.summaryDx),
                subtitle: Text(e.visitTime.toString()),
              );
            },
          ),
        ),
      ],
    );
  }
}
