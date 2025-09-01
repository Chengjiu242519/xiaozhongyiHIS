import 'package:flutter/material.dart';
import '../common/mokuai_header.dart';

class MobanPage extends StatefulWidget {
  const MobanPage({super.key});
  @override
  State<MobanPage> createState() => _MobanPageState();
}

class _MobanPageState extends State<MobanPage> {
  final neirongList = <MobanItem>[
    MobanItem('感冒中医处方', '荆防败毒散 加减 …'),
    MobanItem('理疗-颈肩松解', '推拿×10 + 刮痧×5'),
    MobanItem('西医-发热常用', '对乙酰氨基酚 0.5g bid ×3d …'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MokuaiHeader(
          '处方模板管理',
          actions: [
            FilledButton.icon(
              onPressed: _xinjian,
              icon: const Icon(Icons.add),
              label: const Text('新建模板'),
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: neirongList.length,
            itemBuilder: (context, i) => Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        neirongList[i].biaoti,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          neirongList[i].neirong,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              onPressed: () => _bianji(i),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => neirongList.removeAt(i)),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _xinjian() async {
    final jieguo = await _mobanDialog(biaoti: '新建模板');
    if (jieguo != null) setState(() => neirongList.add(jieguo));
  }

  Future<void> _bianji(int i) async {
    final jieguo = await _mobanDialog(biaoti: '编辑模板', yuchu: neirongList[i]);
    if (jieguo != null) setState(() => neirongList[i] = jieguo);
  }

  Future<MobanItem?> _mobanDialog({
    required String biaoti,
    MobanItem? yuchu,
  }) async {
    final btCtrl = TextEditingController(text: yuchu?.biaoti);
    final nrCtrl = TextEditingController(text: yuchu?.neirong);
    return showDialog<MobanItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(biaoti),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: '模板标题'),
                controller: btCtrl,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: '模板内容'),
                controller: nrCtrl,
                maxLines: 10,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              MobanItem(btCtrl.text.trim(), nrCtrl.text.trim()),
            ),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class MobanItem {
  MobanItem(this.biaoti, this.neirong);
  String biaoti;
  String neirong;
}
