import 'package:flutter/material.dart';
import '../common/mokuai_header.dart';
import '../common/form_helpers.dart';

class MenZhenPage extends StatefulWidget {
  const MenZhenPage({super.key});
  @override
  State<MenZhenPage> createState() => _MenZhenPageState();
}

class _MenZhenPageState extends State<MenZhenPage> {
  DateTimeRange? wanchengJiezhenFanwei;
  final TextEditingController rizhiCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, jiegou) {
        final kuandu = jiegou.maxWidth;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: kuandu * 0.25,
              child: HuanzheLan(
                dianjiXuanFanwei: () async {
                  final xianzai = DateTime.now();
                  final xuanzhe = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(xianzai.year - 1),
                    lastDate: DateTime(xianzai.year + 1),
                  );
                  if (xuanzhe != null) {
                    setState(() => wanchengJiezhenFanwei = xuanzhe);
                  }
                },
                wanchengFanwei: wanchengJiezhenFanwei,
              ),
            ),
            const VerticalDivider(width: 1),
            const Expanded(child: BingliLan()),
            const VerticalDivider(width: 1),
            SizedBox(width: kuandu * 0.25, child: const LishiLan()),
          ],
        );
      },
    );
  }
}

class HuanzheLan extends StatelessWidget {
  const HuanzheLan({
    super.key,
    required this.dianjiXuanFanwei,
    required this.wanchengFanwei,
  });
  final VoidCallback dianjiXuanFanwei;
  final DateTimeRange? wanchengFanwei;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MokuaiHeader(
          '患者',
          actions: [
            FilledButton.tonal(
              onPressed: dianjiXuanFanwei,
              child: const Text('筛选时间段'),
            ),
          ],
        ),
        if (wanchengFanwei != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '完成接诊：${wanchengFanwei!.start.toString().split(' ').first} - ${wanchengFanwei!.end.toString().split(' ').first}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              _lanBiaoti(context, '正在接诊（固定显示）'),
              ...List.generate(
                2,
                (i) => _huanzheTile(context, 'ZhangSan$i', '1380000$i'),
              ),
              const SizedBox(height: 8),
              _lanBiaoti(context, '当天完成接诊'),
              ...List.generate(
                8,
                (i) => _huanzheTile(context, 'LiSi$i', '1390000$i'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lanBiaoti(BuildContext context, String wenzi) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(wenzi, style: Theme.of(context).textTheme.titleSmall),
  );

  Widget _huanzheTile(BuildContext context, String xingming, String shouji) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text('$xingming  ·  $shouji'),
        subtitle: const Text('点击切换到该患者病历'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

class BingliLan extends StatefulWidget {
  const BingliLan({super.key});
  @override
  State<BingliLan> createState() => _BingliLanState();
}

class _BingliLanState extends State<BingliLan> {
  final _biaodanKey = GlobalKey<FormState>();
  final caseScrollCtrl = ScrollController(); // 修复 Scrollbar 报错
  final chufangList = <ChufangItem>[];
  final yizhuList = <String>[];

  @override
  void dispose() {
    caseScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MokuaiHeader('门诊病历'),
        Expanded(
          child: Scrollbar(
            controller: caseScrollCtrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: caseScrollCtrl,
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _biaodanKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _kapian(context, '患者基本信息', _jibenXinxi()),
                    _kapian(context, '就诊信息', _jiuzhenXinxi()),
                    _kapian(
                      context,
                      '处方',
                      _chufangListUi(),
                      headerAnniu: [
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => _tanchuangChufang(
                                context,
                                ChufangLeixing.zhongyi,
                              ),
                              child: const Text('中医处方'),
                            ),
                            OutlinedButton(
                              onPressed: () => _tanchuangChufang(
                                context,
                                ChufangLeixing.liliao,
                              ),
                              child: const Text('理疗处方'),
                            ),
                            OutlinedButton(
                              onPressed: () => _tanchuangChufang(
                                context,
                                ChufangLeixing.xiyi,
                              ),
                              child: const Text('西医处方'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _kapian(
                      context,
                      '医嘱',
                      _yizhuListUi(),
                      headerAnniu: [
                        IconButton(
                          tooltip: '添加医嘱',
                          onPressed: () async {
                            final wenben = await _bianjiDuihua(
                              context,
                              biaoti: '添加医嘱',
                            );
                            if (wenben != null && wenben.trim().isNotEmpty) {
                              setState(() => yizhuList.add(wenben.trim()));
                            }
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    _kapian(
                      context,
                      '就诊日志',
                      TextFormField(
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: '填写本次就诊日志…',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('仅UI演示：保存'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _kapian(
    BuildContext context,
    String biaoti,
    Widget neirong, {
    List<Widget>? headerAnniu,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MokuaiHeader(
            biaoti,
            actions: headerAnniu,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          Padding(padding: const EdgeInsets.all(16), child: neirong),
        ],
      ),
    );
  }

  Widget _jibenXinxi() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: TextFormField(decoration: labelInput('姓名'))),
            gap12(),
            Expanded(child: TextFormField(decoration: labelInput('年龄'))),
            gap12(),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: labelInput('性别'),
                items: const [
                  DropdownMenuItem(value: '男', child: Text('男')),
                  DropdownMenuItem(value: '女', child: Text('女')),
                ],
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextFormField(decoration: labelInput('住址'))),
            gap12(),
            Expanded(
              child: TextFormField(decoration: labelInput('电话号码（唯一标识）')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextFormField(decoration: labelInput('过敏史'))),
            gap12(),
            Expanded(child: TextFormField(decoration: labelInput('既往史'))),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(decoration: labelInput('备注'), maxLines: 2),
      ],
    );
  }

  Widget _jiuzhenXinxi() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: TextFormField(decoration: labelInput('主诉'))),
            gap12(),
            Expanded(child: TextFormField(decoration: labelInput('现病史'))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextFormField(decoration: labelInput('临床诊断'))),
            gap12(),
            Expanded(child: TextFormField(decoration: labelInput('中医诊断'))),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(decoration: labelInput('备注'), maxLines: 2),
      ],
    );
  }

  Widget _chufangListUi() {
    if (chufangList.isEmpty) return const Text('暂无处方，点击上方按钮添加');
    return Column(
      children: chufangList
          .asMap()
          .entries
          .map(
            (e) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  '${e.value.leixing.label} · ${e.value.biaoti ?? '未命名'}',
                ),
                subtitle: Text(
                  e.value.gaiyao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: '编辑',
                      onPressed: () async {
                        final xiugai = await _tanchuangChufang(
                          context,
                          e.value.leixing,
                          yuchu: e.value,
                        );
                        if (xiugai != null) {
                          setState(() => chufangList[e.key] = xiugai);
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: '删除',
                      onPressed: () =>
                          setState(() => chufangList.removeAt(e.key)),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _yizhuListUi() {
    if (yizhuList.isEmpty) return const Text('暂无医嘱');
    return Column(
      children: yizhuList
          .asMap()
          .entries
          .map(
            (e) => ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(e.value),
              trailing: IconButton(
                tooltip: '删除',
                onPressed: () => setState(() => yizhuList.removeAt(e.key)),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          )
          .toList(),
    );
  }

  Future<ChufangItem?> _tanchuangChufang(
    BuildContext context,
    ChufangLeixing leixing, {
    ChufangItem? yuchu,
  }) async {
    final biaotiCtrl = TextEditingController(text: yuchu?.biaoti);
    final neirongCtrl = TextEditingController(text: yuchu?.neirong);
    return showDialog<ChufangItem>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('添加/编辑 ${leixing.label}'),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: biaotiCtrl,
                decoration: const InputDecoration(labelText: '标题/名称'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: neirongCtrl,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: leixing == ChufangLeixing.zhongyi
                      ? '处方明细（药材、剂量、用法）'
                      : leixing == ChufangLeixing.liliao
                      ? '理疗项目与频次'
                      : '药品、剂量、用法',
                ),
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
              ChufangItem(
                leixing: leixing,
                biaoti: biaotiCtrl.text.trim().isEmpty
                    ? null
                    : biaotiCtrl.text.trim(),
                neirong: neirongCtrl.text.trim(),
              ),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<String?> _bianjiDuihua(
    BuildContext context, {
    required String biaoti,
    String? chushi,
  }) async {
    final ctrl = TextEditingController(text: chushi ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(biaoti),
        content: TextField(
          controller: ctrl,
          maxLines: 6,
          decoration: const InputDecoration(hintText: '请输入…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class ChufangItem {
  ChufangItem({required this.leixing, this.biaoti, this.neirong = ''});
  final ChufangLeixing leixing;
  final String? biaoti;
  final String neirong;
  String get gaiyao => neirong.isEmpty ? '（无明细）' : neirong;
}

enum ChufangLeixing { zhongyi, liliao, xiyi }

extension ChufangLeixingExt on ChufangLeixing {
  String get label => switch (this) {
    ChufangLeixing.zhongyi => '中医处方',
    ChufangLeixing.liliao => '理疗处方',
    ChufangLeixing.xiyi => '西医处方',
  };
}

class LishiLan extends StatefulWidget {
  const LishiLan({super.key});
  @override
  State<LishiLan> createState() => _LishiLanState();
}

class _LishiLanState extends State<LishiLan> {
  DateTimeRange? shijianFanwei;
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
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 1),
                );
                if (picked != null) setState(() => shijianFanwei = picked);
              },
              icon: const Icon(Icons.filter_alt_outlined),
            ),
          ],
        ),
        if (shijianFanwei != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '时间：${shijianFanwei!.start.toString().split(' ').first} - ${shijianFanwei!.end.toString().split(' ').first}',
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
                onTap: () => _dakaiLishiXiangqing(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _dakaiLishiXiangqing(BuildContext context) {
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
