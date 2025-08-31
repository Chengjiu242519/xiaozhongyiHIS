import 'package:flutter/material.dart';
import '../common/common_widgets.dart';

class LiliaoPage extends StatefulWidget {
  const LiliaoPage({super.key});
  @override
  State<LiliaoPage> createState() => _LiliaoPageState();
}

class _LiliaoPageState extends State<LiliaoPage> {
  DateTimeRange? xiaociFanwei;
  int jiluTab = 0; // 0 单项目；1 套餐

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MokuaiHeader('待消次（单项目/套餐）'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    const Text('单项目'),
                    ...List.generate(
                      6,
                      (i) => Card(
                        child: ListTile(
                          title: const Text('WangWu  ·  推拿'),
                          subtitle: Text('剩余：${3 - (i % 3)} 次'),
                          trailing: FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('消一次'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('套餐'),
                    ...List.generate(
                      6,
                      (i) => Card(
                        child: ListTile(
                          title: const Text('ZhaoLiu  ·  套餐A'),
                          subtitle: const Text('推拿×10 · 艾灸×5  剩余：推拿7 / 艾灸3'),
                          trailing: FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('消一次'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MokuaiHeader('理疗项目 / 套餐管理（上下）'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Expanded(
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const MokuaiHeader(
                                '理疗项目',
                                caozuoAnniu: [SizedBox()],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: 8,
                                  itemBuilder: (context, i) => ListTile(
                                    leading: const Icon(
                                      Icons.local_hospital_outlined,
                                    ),
                                    title: Text('项目 ${i + 1}'),
                                    subtitle: const Text('价格：¥88  备注：—'),
                                    trailing: Wrap(
                                      spacing: 4,
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.edit_outlined),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.add),
                                    label: const Text('新增项目'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const MokuaiHeader(
                                '理疗套餐',
                                caozuoAnniu: [SizedBox()],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: 6,
                                  itemBuilder: (context, i) => ListTile(
                                    leading: const Icon(
                                      Icons.collections_bookmark_outlined,
                                    ),
                                    title: Text('套餐 ${i + 1}'),
                                    subtitle: const Text('由多种项目组成，次数不同'),
                                    trailing: Wrap(
                                      spacing: 4,
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.edit_outlined),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.add),
                                    label: const Text('新增套餐'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        SizedBox(
          width: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MokuaiHeader(
                '消次记录',
                caozuoAnniu: [
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('单项目')),
                      ButtonSegment(value: 1, label: Text('套餐')),
                    ],
                    selected: {jiluTab},
                    onSelectionChanged: (s) =>
                        setState(() => jiluTab = s.first),
                  ),
                  IconButton(
                    tooltip: '选择时间范围',
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 1),
                      );
                      if (picked != null) setState(() => xiaociFanwei = picked);
                    },
                    icon: const Icon(Icons.filter_alt_outlined),
                  ),
                ],
              ),
              if (xiaociFanwei != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '时间：${xiaociFanwei!.start.toString().split(' ').first} - ${xiaociFanwei!.end.toString().split(' ').first}',
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: 20,
                  itemBuilder: (context, i) => ListTile(
                    title: Text(
                      jiluTab == 0
                          ? '2025-08-${(i + 1).toString().padLeft(2, '0')}  ZhaoLiu  ·  推拿（单项目）'
                          : '2025-08-${(i + 1).toString().padLeft(2, '0')}  ZhaoLiu  ·  套餐A（套餐）',
                    ),
                    subtitle: const Text('扣除 1 次'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
