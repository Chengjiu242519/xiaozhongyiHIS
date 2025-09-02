import 'package:flutter/material.dart';
import '../../../common/mokuai_header.dart';
import '../../../common/form_helpers.dart';
import '../../../db/db.dart';
import '../../models/chufang.dart';
import '../../models/patient.dart';

class BingliLan extends StatefulWidget {
  const BingliLan({super.key, this.patient});
  final Patient? patient; // 建议4：接收外部选中患者
  @override
  State<BingliLan> createState() => _BingliLanState();
}

class _BingliLanState extends State<BingliLan> {
  final _nameFocus = FocusNode(); // 配合 _name 控制 RawAutocomplete 的焦点
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();
  final chufangList = <ChufangItem>[];
  final yizhuList = <String>[];

  // 控制器：用于把“选中患者”的基础信息带入表单
  final _name = TextEditingController();
  final _age = TextEditingController();
  String? _gender;
  final _addr = TextEditingController();
  final _phone = TextEditingController();
  final _allergy = TextEditingController();
  final _history = TextEditingController();
  final _remarkBase = TextEditingController();

  final _complaint = TextEditingController();
  final _present = TextEditingController();
  final _diagCli = TextEditingController();
  final _diagTcm = TextEditingController();
  final _remarkVisit = TextEditingController();

  bool _patientLocked = false; // 是否已锁定为“当前就诊的患者”
  Patient? _lockedPatient; // 已锁定的患者

  @override
  void initState() {
    super.initState();
    _fillFromPatient(widget.patient);
  }

  @override
  void didUpdateWidget(covariant BingliLan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient?.id != widget.patient?.id) {
      _fillFromPatient(widget.patient); // 切换选中患者时重填
    }
  }

  void _fillFromPatient(Patient? p) {
    _lockedPatient = p;
    _patientLocked = p != null;

    _name.text = p?.name ?? '';
    _phone.text = p?.phone ?? '';
    _gender = p?.gender;

    setState(() {});
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    for (final c in [
      _name,
      _age,
      _addr,
      _phone,
      _allergy,
      _history,
      _remarkBase,
      _complaint,
      _present,
      _diagCli,
      _diagTcm,
      _remarkVisit,
      _nameFocus,
    ]) {
      c.dispose();
    }
    super.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      // 示例：保存/更新患者与就诊（需按你的表结构调整）
      // 1) upsert 患者（以 phone 作为唯一标识）
      await Db.execute(
        'INSERT INTO huanzhe (name, phone, gender, addr, allergy, history, remark)\n'
        'VALUES (:name, :phone, :gender, :addr, :allergy, :history, :remark)\n'
        'ON CONFLICT(phone) DO UPDATE SET\n'
        ' name=:name, gender=:gender, addr=:addr, allergy=:allergy, history=:history, remark=:remark',
        {
          'name': _name.text.trim(),
          'phone': _phone.text.trim(),
          'gender': _gender,
          'addr': _addr.text.trim(),
          'allergy': _allergy.text.trim(),
          'history': _history.text.trim(),
          'remark': _remarkBase.text.trim(),
        },
      );

      // 2) 新建就诊记录（示例）
      await Db.execute(
        'INSERT INTO jiuzhen (phone, complaint, present, diag_cli, diag_tcm, remark)\n'
        'VALUES (:phone, :complaint, :present, :diag_cli, :diag_tcm, :remark)',
        {
          'phone': _phone.text.trim(),
          'complaint': _complaint.text.trim(),
          'present': _present.text.trim(),
          'diag_cli': _diagCli.text.trim(),
          'diag_tcm': _diagTcm.text.trim(),
          'remark': _remarkVisit.text.trim(),
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存成功')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MokuaiHeader('门诊病历'),
        Expanded(
          child: Scrollbar(
            controller: _scrollCtrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _kapian(context, '患者基本信息', _jibenXinxi()),
                    _kapian(context, '就诊信息', _jiuzhenXinxi()),
                    _kapian(
                      context,
                      '处方',
                      _chufangListUi(),
                      headerAnniu: _chufangBtns(),
                    ),
                    _kapian(
                      context,
                      '医嘱',
                      _yizhuListUi(),
                      headerAnniu: _yizhuBtns(),
                    ),
                    _kapian(
                      context,
                      '就诊日志',
                      TextFormField(
                        controller: _remarkVisit,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton.icon(
                            onPressed:
                                _save, // 如果 _save 是异步函数，请改成：() async => await _save(),
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('保存'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonal(
                            onPressed: () async {
                              // 先保存一次
                              await _save(); // 如果 _save 不是 async，就去掉 await
                              // 完成接诊时移出“就诊中”
                              if (_lockedPatient?.id != null) {
                                await Db.execute(
                                  'DELETE FROM jiuzhen_session WHERE patient_id=:pid',
                                  {'pid': _lockedPatient!.id},
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('已完成接诊')),
                                  );
                                }
                              }
                            },
                            child: const Text('完成接诊'),
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
      ],
    );
  }

  Widget _kapian(
    BuildContext context,
    String title,
    Widget body, {
    List<Widget>? headerAnniu,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MokuaiHeader(
            title,
            actions: headerAnniu,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          Padding(padding: const EdgeInsets.all(16), child: body),
        ],
      ),
    );
  }

  Widget _jibenXinxi() {
    // 本地查患者（姓名/电话）
    Future<List<Patient>> _searchPatients(String kw) async {
      if (kw.trim().isEmpty) return [];
      final rs = await Db.query(
        'SELECT id, name, phone, gender FROM huanzhe '
        'WHERE name LIKE :kw OR phone LIKE :kw '
        'ORDER BY id DESC LIMIT 20',
        {'kw': '%$kw%'},
      );
      return rs.rows.map(Patient.fromRow).toList();
    }

    // 点击“开始就诊”：把患者写入 jiuzhen_session，并锁定
    Future<void> _startVisitFor(Patient p) async {
      await Db.execute(
        'INSERT INTO jiuzhen_session (patient_id) VALUES (:pid) '
        'ON DUPLICATE KEY UPDATE updated_at=NOW()',
        {'pid': p.id},
      );
      setState(() {
        _lockedPatient = p;
        _patientLocked = true;
        _name.text = p.name;
        _phone.text = p.phone ?? '';
        _gender = p.gender;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已开始就诊')));
    }

    // 仅“保存草稿并更换患者”：不移出就诊中，只解锁让你重新搜索
    void _saveDraftAndUnlock() {
      // 这里如需本地持久化草稿，可自行补充（例如写到 jiuzhen_draft）
      setState(() {
        _patientLocked = false;
        _lockedPatient = null;
        _name.clear();
        // 其他需要重置的基础信息字段按需清理
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('草稿已保存，可切换患者')));
    }

    return Column(
      children: [
        // 顶部：姓名 + 年龄 + 性别 + 住址 + 电话
        Row(
          children: [
            // 姓名：未锁定 → 自动补全 + “开始就诊”；已锁定 → 只读 + “更换患者”
            Expanded(
              child: _patientLocked
                  ? Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _name,
                            readOnly: true,
                            decoration: labelInput('姓名（已锁定）'),
                            validator: _req,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: '保存草稿并更换患者',
                          onPressed: _saveDraftAndUnlock,
                          icon: const Icon(Icons.person_remove_alt_1_outlined),
                        ),
                      ],
                    )
                  : RawAutocomplete<Patient>(
                      textEditingController: _name,
                      focusNode: _nameFocus,
                      optionsBuilder: (TextEditingValue tev) async {
                        return _searchPatients(tev.text);
                      },
                      displayStringForOption: (p) =>
                          '${p.name}  ${p.phone ?? ''}',
                      fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
                        return TextFormField(
                          controller: ctrl,
                          focusNode: focus,
                          decoration: labelInput('姓名（输入自动匹配）'),
                          validator: _req,
                        );
                      },
                      optionsViewBuilder: (ctx, onSelected, options) {
                        return Material(
                          elevation: 4,
                          child: ListView(
                            shrinkWrap: true,
                            children: options.map((p) {
                              return ListTile(
                                title: Text('${p.name}  ${p.phone ?? ''}'),
                                onTap: () => onSelected(p),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      onSelected: (p) async {
                        // 选中后再点“开始就诊”更稳妥，这里直接打开确认
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('开始就诊'),
                            content: Text('确定为【${p.name}】开始就诊？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('取消'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('确定'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) await _startVisitFor(p);
                      },
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _age,
                decoration: labelInput('年龄'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: '男', child: Text('男')),
                  DropdownMenuItem(value: '女', child: Text('女')),
                ],
                onChanged: _patientLocked
                    ? null
                    : (v) => setState(() => _gender = v),
                decoration: labelInput('性别'),
              ),
            ),
          ],
        ),
        gap12(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _addr,
                decoration: labelInput('住址'),
                readOnly: _patientLocked ? false : false, // 住址可根据你需求是否锁定
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _phone,
                decoration: labelInput('电话号码（唯一标识）'),
                validator: _req,
                readOnly: _patientLocked, // 锁定后不允许改基础信息
              ),
            ),
          ],
        ),
        gap12(),
        Row(
          children: [
            // 左侧保留原有“过敏史/既往史”等…
            Expanded(
              child: TextFormField(
                controller: _allergy,
                decoration: labelInput('过敏史'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _history,
                decoration: labelInput('既往史'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _jiuzhenXinxi() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _complaint,
                decoration: labelInput('主诉'),
                validator: _req,
              ),
            ),
            gap12(),
            Expanded(
              child: TextFormField(
                controller: _present,
                decoration: labelInput('现病史'),
              ),
            ),
          ],
        ),
        gap12(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _diagCli,
                decoration: labelInput('临床诊断'),
              ),
            ),
            gap12(),
            Expanded(
              child: TextFormField(
                controller: _diagTcm,
                decoration: labelInput('中医诊断'),
              ),
            ),
          ],
        ),
        gap12(),
        TextFormField(decoration: labelInput('备注'), maxLines: 2),
      ],
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? '必填' : null;

  List<Widget> _chufangBtns() => [
    Wrap(
      spacing: 8,
      children: [
        OutlinedButton(
          onPressed: () => _editChufang(context, ChufangLeixing.zhongyi),
          child: const Text('中医处方'),
        ),
        OutlinedButton(
          onPressed: () => _editChufang(context, ChufangLeixing.liliao),
          child: const Text('理疗处方'),
        ),
        OutlinedButton(
          onPressed: () => _editChufang(context, ChufangLeixing.xiyi),
          child: const Text('西医处方'),
        ),
      ],
    ),
  ];

  List<Widget> _yizhuBtns() => [
    IconButton(
      tooltip: '添加医嘱',
      onPressed: () async {
        final txt = await _editText(context, title: '添加医嘱');
        if (txt != null && txt.trim().isNotEmpty)
          setState(() => yizhuList.add(txt.trim()));
      },
      icon: const Icon(Icons.add),
    ),
  ];

  Widget _chufangListUi() {
    if (chufangList.isEmpty) return const Text('暂无处方，点击上方按钮添加');
    return Column(
      children: chufangList.asMap().entries.map((e) {
        final i = e.key;
        final it = e.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('${it.leixing.label} · ${it.biaoti ?? '未命名'}'),
            subtitle: Text(
              it.gaiyao,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: '编辑',
                  onPressed: () async {
                    final v = await _editChufang(context, it.leixing, init: it);
                    if (v != null) setState(() => chufangList[i] = v);
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: '删除',
                  onPressed: () => setState(() => chufangList.removeAt(i)),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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

  Future<ChufangItem?> _editChufang(
    BuildContext context,
    ChufangLeixing type, {
    ChufangItem? init,
  }) async {
    final title = TextEditingController(text: init?.biaoti);
    final content = TextEditingController(text: init?.neirong);
    final v = await showDialog<ChufangItem>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('添加/编辑 ${type.label}'),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: '标题/名称'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: content,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: switch (type) {
                    ChufangLeixing.zhongyi => '处方明细（药材、剂量、用法）',
                    ChufangLeixing.liliao => '理疗项目与频次',
                    ChufangLeixing.xiyi => '药品、剂量、用法',
                  },
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
                leixing: type,
                biaoti: title.text.trim().isEmpty ? null : title.text.trim(),
                neirong: content.text.trim(),
              ),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return v;
  }

  Future<String?> _editText(
    BuildContext context, {
    required String title,
    String? init,
  }) async {
    final c = TextEditingController(text: init ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          maxLines: 6,
          decoration: const InputDecoration(hintText: '请输入…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
