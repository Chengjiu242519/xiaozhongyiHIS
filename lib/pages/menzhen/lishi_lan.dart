import 'package:flutter/material.dart';
import '../../../common/mokuai_header.dart';

class LishiLan extends StatelessWidget {
  const LishiLan({
    super.key,
    required this.onTapPickRange,
    required this.wanchengFanwei,
  });
  final VoidCallback onTapPickRange;
  final DateTimeRange? wanchengFanwei;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MokuaiHeader(
          '历史就诊记录',
          actions: [
            IconButton(
              tooltip: '选择时间范围',
              onPressed: onTapPickRange,
              icon: const Icon(Icons.filter_alt_outlined),
            ),
          ],
        ),
        if (wanchengFanwei != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '时间：${wanchengFanwei!.start.toString().split(' ').first} — ${wanchengFanwei!.end.toString().split(' ').first}',
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: 12,
            itemBuilder: (context, i) => Card(
              child: ListTile(
                title: Text(
                  '2025-08-${(i + 1).toString().padLeft(2, '0')} 就诊记录',
                ),
                subtitle: const Text('点击查看详情并复制处方/医嘱到本次就诊'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openDetail(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('历史就诊详情'),
        content: SizedBox(
          width: 720,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('基本信息：张三 · 男 · 35岁'),
                SizedBox(height: 8),
                Text('诊断：感冒 · 风寒感冒'),
                SizedBox(height: 8),
                Divider(),
                Text('处方：'),
                SizedBox(height: 4),
                Text('中医处方：荆防败毒散 加减 …'),
                Text('西医处方：对乙酰氨基酚 0.5g bid ×3d …'),
                SizedBox(height: 8),
                Text('医嘱：多喝温水，注意休息'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () {}, child: const Text('复制处方到当前就诊')),
          TextButton(onPressed: () {}, child: const Text('复制医嘱到当前就诊')),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
