import 'package:flutter/material.dart';
import '../../shuju_moban/huanzhe.dart';
import '../../shuju_moban/huanzhe_xinxi.dart';
import '../../shuju_moban/menzhen_caogao.dart';

class BingLiLan extends StatefulWidget {
  final Huanzhe? huanzhe;
  final HuanzheXinXi? huanzheXinxi; // 仅允许编辑 3 项（就诊中可改；完成态只读）
  final MenZhenCaoGao? caogao; // 病历主数据
  final bool wanCheng; // 是否为“已完成病历”模式
  final bool xiuGaiMoShi; // 是否处于“修改已完成病历”模式

  // 新增：完成态打开时的医嘱/门诊日志初值（用于回显）
  final String? yizhuTextChuShi;
  final String? rizhiTextChuShi;

  // 回调
  final Future<void> Function(
    String? guominshi,
    String? jiwangshi,
    String? beizhu,
  )
  onBaocunHuanzheXinxi; // 接诊完成时覆盖到 huanzhe
  final Future<void> Function({
    String? zhusu,
    String? xianbingshi,
    String? linchuangDx,
    String? zhongyiDx,
    String? beizhu,
  })
  onBaocun; // 就诊中保存草稿
  final Future<void> Function() onWancheng; // 接诊完成
  final Future<void> Function(List<String> lines) onBaocunYiZhu; // 预留（当前未用）
  final Future<void> Function(String content)
  onTianjiaRiZhi; // 记录门诊日志（就诊中保存/完成时写）

  // 删除/修改/退款
  final Future<void> Function() onShanchuZaiZhen; // 就诊中删除（删会话+草稿）
  final Future<void> Function() onShanchuWanCheng; // 已完成删除（删该次就诊）
  final Future<void> Function() onXiugaiWanCheng; // 进入“修改模式”
  final Future<void> Function({
    String? zhusu,
    String? xianbingshi,
    String? linchuangDx,
    String? zhongyiDx,
    String? beizhu,
    String? yizhuText,
    String? rizhiText,
  })
  onBaoCunXiuGai; // 保存修改（覆盖原就诊记录，含医嘱/日志）
  final Future<void> Function() onTuikuan; // 退款（占位）
  final VoidCallback? onQuxiaoXiuGai; // 取消修改（可选）

  const BingLiLan({
    super.key,
    required this.huanzhe,
    required this.huanzheXinxi,
    required this.caogao,
    required this.wanCheng,
    required this.xiuGaiMoShi,
    this.yizhuTextChuShi,
    this.rizhiTextChuShi,
    required this.onBaocunHuanzheXinxi,
    required this.onBaocun,
    required this.onWancheng,
    required this.onBaocunYiZhu,
    required this.onTianjiaRiZhi,
    required this.onShanchuZaiZhen,
    required this.onShanchuWanCheng,
    required this.onXiugaiWanCheng,
    required this.onBaoCunXiuGai,
    required this.onTuikuan,
    this.onQuxiaoXiuGai,
  });

  @override
  State<BingLiLan> createState() => _BingLiLanState();
}

class _BingLiLanState extends State<BingLiLan> {
  // 基础信息（仅 3 项可改；完成态只读）
  final _gm = TextEditingController();
  final _jw = TextEditingController();
  final _hzbz = TextEditingController();

  // 病历主数据
  final _zhusu = TextEditingController();
  final _xbs = TextEditingController();
  final _lcdx = TextEditingController();
  final _zydx = TextEditingController();
  final _blbz = TextEditingController();

  // 医嘱/门诊日志（普通多行文本）
  final _yizhu = TextEditingController();
  final _rizhi = TextEditingController();

  @override
  void didUpdateWidget(covariant BingLiLan oldWidget) {
    super.didUpdateWidget(oldWidget);
    _restoreFields();
  }

  @override
  void initState() {
    super.initState();
    _restoreFields();
  }

  void _restoreFields() {
    final x = widget.huanzheXinxi;
    _gm.text = x?.guominshi ?? '';
    _jw.text = x?.jiwangshi ?? '';
    _hzbz.text = x?.huanzheBeizhu ?? '';

    final d = widget.caogao;
    _zhusu.text = d?.zhusu ?? '';
    _xbs.text = d?.xianbingshi ?? '';
    _lcdx.text = d?.linchuangDx ?? '';
    _zydx.text = d?.zhongyiDx ?? '';
    _blbz.text = d?.beizhu ?? '';

    // 完成态打开时回显医嘱/日志
    if (widget.yizhuTextChuShi != null) _yizhu.text = widget.yizhuTextChuShi!;
    if (widget.rizhiTextChuShi != null) _rizhi.text = widget.rizhiTextChuShi!;
  }

  int _calcAge(DateTime? birthday) {
    if (birthday == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  SnackBar _snack(String text) => SnackBar(
    content: Text(text),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(bottom: 72, left: 16, right: 16),
  );

  @override
  Widget build(BuildContext context) {
    final p = widget.huanzhe;
    if (p == null) return const Center(child: Text('未选择患者'));

    // 只读逻辑：
    // - 就诊中：可编辑
    // - 已完成：只读；若进入“修改模式” -> 主数据 + 医嘱/日志可编辑；基础信息仍只读
    final readOnlyBL = widget.wanCheng ? !widget.xiuGaiMoShi : false;
    final readOnlyExt = widget.wanCheng; // 完成态基础信息始终只读
    final readOnlyYZRZ = widget.wanCheng ? !widget.xiuGaiMoShi : false;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) 患者基础信息
                _kuaiTitle('患者基础信息'),
                _kuai(
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _rowInfo('姓名', p.name),
                          _rowInfo('性别', p.gender ?? '未知'),
                          _rowInfo('年龄', _calcAge(p.birthday).toString()),
                          _rowInfo(
                            '生日',
                            p.birthday?.toIso8601String().substring(0, 10) ??
                                '',
                          ),
                          _rowInfo('电话', p.phone),
                          const Divider(),
                          TextField(
                            controller: _gm,
                            maxLines: 2,
                            readOnly: readOnlyExt,
                            decoration: const InputDecoration(
                              labelText: '过敏史（就诊中可修改）',
                            ),
                          ),
                          TextField(
                            controller: _jw,
                            maxLines: 2,
                            readOnly: readOnlyExt,
                            decoration: const InputDecoration(
                              labelText: '既往史（就诊中可修改）',
                            ),
                          ),
                          TextField(
                            controller: _hzbz,
                            maxLines: 2,
                            readOnly: readOnlyExt,
                            decoration: const InputDecoration(
                              labelText: '患者备注（就诊中可修改）',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2) 病历主数据
                _kuaiTitle('病历主数据'),
                _kuai(
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextField(
                            controller: _zhusu,
                            maxLines: 2,
                            readOnly: readOnlyBL,
                            decoration: const InputDecoration(labelText: '主诉'),
                          ),
                          TextField(
                            controller: _xbs,
                            maxLines: 4,
                            readOnly: readOnlyBL,
                            decoration: const InputDecoration(labelText: '现病史'),
                          ),
                          TextField(
                            controller: _lcdx,
                            readOnly: readOnlyBL,
                            decoration: const InputDecoration(
                              labelText: '临床诊断',
                            ),
                          ),
                          TextField(
                            controller: _zydx,
                            readOnly: readOnlyBL,
                            decoration: const InputDecoration(
                              labelText: '中医诊断',
                            ),
                          ),
                          TextField(
                            controller: _blbz,
                            maxLines: 3,
                            readOnly: readOnlyBL,
                            decoration: const InputDecoration(
                              labelText: '病历备注',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3) 处方（后续接入）
                _kuaiTitle('处方（中医 / 理疗 / 西医）— 后续接入'),
                _kuai(
                  const Card(
                    child: SizedBox(
                      height: 60,
                      child: Center(child: Text('此处暂留')),
                    ),
                  ),
                ),

                // 4) 医嘱（普通文本；修改模式可编辑）
                _kuaiTitle('医嘱（普通文本，多行）'),
                _kuai(
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _yizhu,
                        maxLines: 6,
                        readOnly: readOnlyYZRZ,
                        decoration: const InputDecoration(hintText: '输入医嘱...'),
                      ),
                    ),
                  ),
                ),

                // 5) 门诊日志（普通文本；修改模式可编辑）
                _kuaiTitle('门诊日志（普通文本，多行）'),
                _kuai(
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _rizhi,
                        maxLines: 6,
                        readOnly: readOnlyYZRZ,
                        decoration: const InputDecoration(
                          hintText: '输入门诊日志...（保存或完成时记录）',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 底部操作条
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            children: [
              if (!widget.wanCheng) ...[
                // 就诊中：保存 / 接诊完成 / 删除
                FilledButton.icon(
                  onPressed: () async {
                    await widget.onBaocun(
                      zhusu: _zhusu.text,
                      xianbingshi: _xbs.text,
                      linchuangDx: _lcdx.text,
                      zhongyiDx: _zydx.text,
                      beizhu: _blbz.text,
                    );
                    final log = _rizhi.text.trim();
                    if (log.isNotEmpty) {
                      await widget.onTianjiaRiZhi(log);
                      _rizhi.clear();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(_snack('已保存'));
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('保存'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    await widget.onBaocun(
                      zhusu: _zhusu.text,
                      xianbingshi: _xbs.text,
                      linchuangDx: _lcdx.text,
                      zhongyiDx: _zydx.text,
                      beizhu: _blbz.text,
                    );
                    await widget.onBaocunHuanzheXinxi(
                      _gm.text,
                      _jw.text,
                      _hzbz.text,
                    );
                    final log = _rizhi.text.trim();
                    if (log.isNotEmpty) {
                      await widget.onTianjiaRiZhi(log);
                      _rizhi.clear();
                    }
                    await widget.onWancheng();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('接诊完成'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    widget.onShanchuZaiZhen();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('删除'),
                ),
              ] else if (!widget.xiuGaiMoShi) ...[
                // 已完成：查看态（只读）
                OutlinedButton.icon(
                  onPressed: () {
                    widget.onXiugaiWanCheng();
                  }, // 进入修改模式
                  icon: const Icon(Icons.edit),
                  label: const Text('修改'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    widget.onTuikuan();
                  },
                  icon: const Icon(Icons.reply),
                  label: const Text('退款'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    widget.onShanchuWanCheng();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('删除'),
                ),
              ] else ...[
                // 已完成：修改模式（覆盖原就诊记录，包含医嘱/日志）
                FilledButton.icon(
                  onPressed: () async {
                    await widget.onBaoCunXiuGai(
                      zhusu: _zhusu.text,
                      xianbingshi: _xbs.text,
                      linchuangDx: _lcdx.text,
                      zhongyiDx: _zydx.text,
                      beizhu: _blbz.text,
                      yizhuText: _yizhu.text,
                      rizhiText: _rizhi.text,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(_snack('修改已保存'));
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('保存修改'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: widget.onQuxiaoXiuGai,
                  icon: const Icon(Icons.close),
                  label: const Text('取消修改'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _kuaiTitle(String t) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(
      t,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
  Widget _kuai(Widget child) =>
      Padding(padding: const EdgeInsets.only(bottom: 12), child: child);
  Widget _rowInfo(String k, String v) => Row(
    children: [
      SizedBox(
        width: 90,
        child: Text('$k：', style: const TextStyle(color: Colors.grey)),
      ),
      Expanded(child: Text(v)),
    ],
  );
}
