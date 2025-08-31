import 'package:flutter/material.dart';
import '../common/common_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 460,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MokuaiHeader(
                '药品录入/编辑',
                caozuoAnniu: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SegmentedButton<YaofangFenlei>(
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
                      ButtonSegment(value: XiyaoZilei.shuye, label: Text('输液')),
                    ],
                    selected: {xiyao},
                    onSelectionChanged: (s) => setState(() => xiyao = s.first),
                  ),
                )
              else
                const SizedBox(height: 12),
              const Expanded(child: YaopinBiaodan()),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MokuaiHeader(
                '药房库存记录',
                caozuoAnniu: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        const Text('筛选：'),
                        if (fenlei == YaofangFenlei.zhongyao)
                          Text(
                            zhongyao == ZhongyaoZilei.yinpian
                                ? '中药·饮片'
                                : '中药·中成药',
                          )
                        else if (fenlei == YaofangFenlei.xiyao)
                          Text(xiyao == XiyaoZilei.chiyao ? '西药·吃药' : '西药·输液')
                        else
                          const Text('耗材'),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 1100,
                      ), // 视情况调大/调小
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columnSpacing: 12, // 可选：缩小列间距
                          columns: const [
                            DataColumn(label: Text('分类')),
                            DataColumn(label: Text('名称')),
                            DataColumn(label: Text('剂型/规格')),
                            DataColumn(label: Text('单位')),
                            DataColumn(label: Text('库存')),
                            DataColumn(label: Text('进价')),
                            DataColumn(label: Text('卖价')),
                            DataColumn(label: Text('推荐用量/默认用法')),
                            DataColumn(label: Text('备注')),
                          ],
                          rows: List.generate(
                            15,
                            (i) => DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    _dangqianFenleiBiaoqian(
                                      fenlei,
                                      zhongyao,
                                      xiyao,
                                    ),
                                  ),
                                ),
                                DataCell(Text('${_duanFenleiMing(fenlei)}名$i')),
                                const DataCell(Text('规格示例')),
                                const DataCell(Text('g')),
                                DataCell(Text('${100 - i}')),
                                const DataCell(Text('0.5')),
                                const DataCell(Text('1.2')),
                                const DataCell(Text('10-15g / 水煎服')),
                                const DataCell(Text('—')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _dangqianFenleiBiaoqian(
    YaofangFenlei f,
    ZhongyaoZilei zy,
    XiyaoZilei xy,
  ) {
    switch (f) {
      case YaofangFenlei.zhongyao:
        return zy == ZhongyaoZilei.yinpian ? '中药·饮片' : '中药·中成药';
      case YaofangFenlei.xiyao:
        return xy == XiyaoZilei.chiyao ? '西药·吃药' : '西药·输液';
      case YaofangFenlei.haocai:
        return '耗材';
    }
  }

  String _duanFenleiMing(YaofangFenlei f) {
    switch (f) {
      case YaofangFenlei.zhongyao:
        return '中药';
      case YaofangFenlei.xiyao:
        return '西药';
      case YaofangFenlei.haocai:
        return '耗材';
    }
  }
}

class YaopinBiaodan extends StatelessWidget {
  const YaopinBiaodan({super.key});
  @override
  Widget build(BuildContext context) {
    Widget hang() => const SizedBox(height: 12);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextFormField(decoration: biaoqianInput('名称')),
          hang(),
          Row(
            children: [
              Expanded(
                child: TextFormField(decoration: biaoqianInput('剂型/规格')),
              ),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(decoration: biaoqianInput('单位'))),
            ],
          ),
          hang(),
          Row(
            children: [
              Expanded(child: TextFormField(decoration: biaoqianInput('库存'))),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(decoration: biaoqianInput('进价'))),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(decoration: biaoqianInput('卖价'))),
            ],
          ),
          hang(),
          Row(
            children: [
              Expanded(child: TextFormField(decoration: biaoqianInput('推荐用量'))),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(decoration: biaoqianInput('默认用法'))),
            ],
          ),
          hang(),
          TextFormField(decoration: biaoqianInput('备注'), maxLines: 2),
          hang(),
          Row(
            children: [
              FilledButton(onPressed: () {}, child: const Text('保存')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () {}, child: const Text('重置')),
            ],
          ),
        ],
      ),
    );
  }
}
