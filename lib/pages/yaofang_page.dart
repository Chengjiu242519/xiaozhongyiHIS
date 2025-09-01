import 'package:flutter/material.dart';
import '../common/mokuai_header.dart';

class YaofangPage extends StatefulWidget {
  const YaofangPage({super.key});
  @override
  State<YaofangPage> createState() => _YaofangPageState();
}

enum YaofangFenlei { zhongyao, xiyao, haocai }

enum ZhongyaoZilei { yinpian, zhongchengyao }

enum XiyaoZilei { chiyao, shuye }

class _YaofangPageState extends State<YaofangPage> {
  YaofangFenlei fenlei = YaofangFenlei.zhongyao;
  ZhongyaoZilei zhongyao = ZhongyaoZilei.yinpian;
  XiyaoZilei xiyao = XiyaoZilei.chiyao;

  // 修复 Scrollbar 报错：为横/纵分别提供 controller，并与各自的 ScrollView 绑定
  final ScrollController _hCtrl = ScrollController();
  final ScrollController _vCtrl = ScrollController();

  // 简单示例数据
  final TextEditingController _mcCtrl = TextEditingController();
  final TextEditingController _ggCtrl = TextEditingController();
  final TextEditingController _bzCtrl = TextEditingController();

  @override
  void dispose() {
    _hCtrl.dispose();
    _vCtrl.dispose();
    _mcCtrl.dispose();
    _ggCtrl.dispose();
    _bzCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 居中 + 自适应：Align + ConstrainedBox 控制最大宽度；小屏可滚动，大屏不发散
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 左侧表单列
              SizedBox(
                width: 460,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MokuaiHeader(
                      '药品录入/编辑',
                      icon: Icons.edit_note_outlined,
                      actions: [
                        SegmentedButton<YaofangFenlei>(
                          segments: const [
                            ButtonSegment(
                              value: YaofangFenlei.zhongyao,
                              label: Text('中药'),
                            ),
                            ButtonSegment(
                              value: YaofangFenlei.xiyao,
                              label: Text('西药'),
                            ),
                            ButtonSegment(
                              value: YaofangFenlei.haocai,
                              label: Text('耗材'),
                            ),
                          ],
                          selected: {fenlei},
                          onSelectionChanged: (s) =>
                              setState(() => fenlei = s.first),
                        ),
                      ],
                    ),
                    if (fenlei == YaofangFenlei.zhongyao)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: SegmentedButton<ZhongyaoZilei>(
                          segments: const [
                            ButtonSegment(
                              value: ZhongyaoZilei.yinpian,
                              label: Text('饮片'),
                            ),
                            ButtonSegment(
                              value: ZhongyaoZilei.zhongchengyao,
                              label: Text('中成药'),
                            ),
                          ],
                          selected: {zhongyao},
                          onSelectionChanged: (s) =>
                              setState(() => zhongyao = s.first),
                        ),
                      )
                    else if (fenlei == YaofangFenlei.xiyao)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: SegmentedButton<XiyaoZilei>(
                          segments: const [
                            ButtonSegment(
                              value: XiyaoZilei.chiyao,
                              label: Text('吃药'),
                            ),
                            ButtonSegment(
                              value: XiyaoZilei.shuye,
                              label: Text('输液'),
                            ),
                          ],
                          selected: {xiyao},
                          onSelectionChanged: (s) =>
                              setState(() => xiyao = s.first),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // 表单体
                    Expanded(
                      child: SingleChildScrollView(
                        primary: false,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _mcCtrl,
                              decoration: _labelInput('名称'),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _ggCtrl,
                              decoration: _labelInput('剂型/规格'),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _bzCtrl,
                              decoration: _labelInput('备注'),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                FilledButton(
                                  onPressed: _onSave,
                                  child: const Text('保存'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: _onReset,
                                  child: const Text('重置'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const VerticalDivider(width: 1),

              // 右侧表格列（自适应 + 双向滚动）
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MokuaiHeader(
                      '药品清单',
                      icon: Icons.inventory_2_outlined,
                      actions: [
                        SizedBox(
                          width: 240,
                          child: TextField(
                            decoration: const InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(Icons.search),
                              hintText: '搜索名称/规格/备注',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (kw) {
                              // TODO: 触发过滤
                            },
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            // TODO: 导出
                          },
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('导出'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _yaopinTable(hCtrl: _hCtrl, vCtrl: _vCtrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    // TODO: 保存逻辑
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已保存（示例）')));
  }

  void _onReset() {
    _mcCtrl.clear();
    _ggCtrl.clear();
    _bzCtrl.clear();
  }
}

// ------------ 小组件 & 工具函数 ------------

InputDecoration _labelInput(String label) {
  return InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
  );
}

/// 列头：图标 + 文字
class _Col extends StatelessWidget {
  const _Col(this.text, this.icon);
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(text, style: style),
      ],
    );
  }
}

/// 药品清单表：双向滚动 + 匹配 Scrollbar controller（避免报错）
Widget _yaopinTable({
  required ScrollController hCtrl,
  required ScrollController vCtrl,
}) {
  return Scrollbar(
    controller: hCtrl,
    thumbVisibility: true,
    interactive: true,
    thickness: 10,
    notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
    child: SingleChildScrollView(
      primary: false,
      scrollDirection: Axis.horizontal,
      controller: hCtrl,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1100),
        child: Scrollbar(
          controller: vCtrl,
          thumbVisibility: true,
          interactive: true,
          thickness: 10,
          notificationPredicate: (n) => n.metrics.axis == Axis.vertical,
          child: SingleChildScrollView(
            primary: false,
            controller: vCtrl,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DataTable(
                columnSpacing: 12,
                headingRowHeight: 40,
                dataRowMinHeight: 40,
                columns: const [
                  DataColumn(label: _Col('分类', Icons.category_outlined)),
                  DataColumn(label: _Col('名称', Icons.label_outline)),
                  DataColumn(label: _Col('剂型/规格', Icons.science_outlined)),
                  DataColumn(label: _Col('单位', Icons.straighten_outlined)),
                  DataColumn(label: _Col('库存', Icons.inventory_outlined)),
                  DataColumn(label: _Col('进价', Icons.download_outlined)),
                  DataColumn(label: _Col('售价', Icons.upload_outlined)),
                  DataColumn(
                    label: _Col('用法用量/说明', Icons.description_outlined),
                  ),
                  DataColumn(label: _Col('备注', Icons.note_outlined)),
                ],
                rows: List<DataRow>.generate(30, (i) {
                  return const DataRow(
                    cells: [
                      DataCell(Text('中药')),
                      DataCell(Text('黄芪')),
                      DataCell(Text('饮片 500g')),
                      DataCell(Text('g')),
                      DataCell(Text('120')),
                      DataCell(Text('0.5')),
                      DataCell(Text('1.2')),
                      DataCell(Text('10-15g / 水煎服')),
                      DataCell(Text('—')),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
