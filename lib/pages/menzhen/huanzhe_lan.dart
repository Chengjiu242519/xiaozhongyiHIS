import 'dart:async';
import 'package:flutter/material.dart';
import '../../../common/mokuai_header.dart';
import '../../../db/db.dart';
import '../../models/patient.dart';

class HuanzheLan extends StatefulWidget {
  const HuanzheLan({
    super.key,
    required this.onTapPickRange,
    required this.wanchengFanwei,
    required this.onSelectPatient,
  });
  final VoidCallback onTapPickRange;
  final DateTimeRange? wanchengFanwei;
  final ValueChanged<Patient> onSelectPatient;

  @override
  State<HuanzheLan> createState() => _HuanzheLanState();
}

class _HuanzheLanState extends State<HuanzheLan> {
  bool _loading = false;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  final _rows = <Patient>[];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final kw = _searchCtrl.text.trim();
      final sql = StringBuffer()
        ..writeln('SELECT h.id, h.name, h.phone, h.gender')
        ..writeln('FROM jiuzhen_session s')
        ..writeln('JOIN huanzhe h ON h.id = s.patient_id');
      Map<String, dynamic>? params;
      if (kw.isNotEmpty) {
        sql.writeln('WHERE h.name LIKE :kw OR h.phone LIKE :kw');
        params = {'kw': '%$kw%'};
      }
      sql.writeln('ORDER BY s.updated_at DESC LIMIT 100');

      final res = await Db.query(sql.toString(), params);
      _rows
        ..clear()
        ..addAll(res.rows.map(Patient.fromRow));
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载就诊中患者失败：$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MokuaiHeader(
          '患者',
          actions: [
            FilledButton.tonal(
              onPressed: widget.onTapPickRange,
              child: const Text('筛选时间段'),
            ),
            IconButton(
              tooltip: '添加新患者',
              onPressed: _openAddPatientDialog,
              icon: const Icon(Icons.person_add_alt_1),
            ),
          ],
        ),

        if (widget.wanchengFanwei != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '完成接诊：${widget.wanchengFanwei!.start.toString().split(' ').first} — ${widget.wanchengFanwei!.end.toString().split(' ').first}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: '搜索姓名或电话',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _load, child: const Text('搜索')),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _rows.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '就诊中',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      );
                    }
                    final p = _rows[i - 1];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_outline),
                      title: Text('${p.name}  (${p.gender ?? '未知'})'),
                      subtitle: Text(
                        '电话: ${p.phone ?? ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'done') {
                            try {
                              await Db.execute(
                                'DELETE FROM jiuzhen_session WHERE patient_id=:pid',
                                {'pid': p.id},
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已标记完成')),
                                );
                                _load(); // 刷新“就诊中”列表
                                _openPatientOverview(p); // 标记完成后仅查看，不打断当前就诊
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('操作失败：$e')),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (ctx) => const [
                          PopupMenuItem(
                            value: 'done',
                            child: Text('标记完成（移出就诊中）'),
                          ),
                        ],
                      ),
                      onTap: () => _openPatientOverview(p),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openPatientOverview(Patient p) async {
    try {
      final base = await Db.query(
        'SELECT name, phone, gender, addr, allergy, history, remark '
        'FROM huanzhe WHERE id=:id',
        {'id': p.id},
      );
      final b = base.rows.isNotEmpty ? base.rows.first : null;

      // 这里按你项目里 jiuzhen 表使用 phone 字段关联（与你的保存逻辑一致）
      final his = await Db.query(
        'SELECT id, created_at, diag_cli, diag_tcm '
        'FROM jiuzhen WHERE phone=:phone ORDER BY id DESC LIMIT 50',
        {'phone': p.phone},
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('【${p.name}】基础信息与就诊记录'),
          content: SizedBox(
            width: 720,
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: '基础信息'),
                      Tab(text: '就诊记录'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 440,
                    child: TabBarView(
                      children: [
                        // 基础信息
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _kv(
                                context,
                                '姓名',
                                (b?.colByName('name') ?? p.name).toString(),
                              ),
                              _kv(
                                context,
                                '电话',
                                (b?.colByName('phone') ?? (p.phone ?? ''))
                                    .toString(),
                              ),
                              _kv(
                                context,
                                '性别',
                                (b?.colByName('gender') ?? (p.gender ?? ''))
                                    .toString(),
                              ),
                              _kv(
                                context,
                                '住址',
                                (b?.colByName('addr') ?? '').toString(),
                              ),
                              _kv(
                                context,
                                '过敏史',
                                (b?.colByName('allergy') ?? '').toString(),
                              ),
                              _kv(
                                context,
                                '既往史',
                                (b?.colByName('history') ?? '').toString(),
                              ),
                              _kv(
                                context,
                                '备注',
                                (b?.colByName('remark') ?? '').toString(),
                              ),
                            ],
                          ),
                        ),
                        // 就诊记录
                        () {
                          final rows = his.rows.toList(); // 关键：先转 List
                          if (rows.isEmpty) {
                            return const Center(child: Text('暂无历史就诊'));
                          }
                          return ListView.separated(
                            itemCount: rows.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final r = rows[i];
                              final vid = int.tryParse(
                                r.colByName('id')?.toString() ?? '',
                              );
                              final time = (r.colByName('created_at') ?? '')
                                  .toString();
                              final dxCli = (r.colByName('diag_cli') ?? '')
                                  .toString();
                              final dxTcm = (r.colByName('diag_tcm') ?? '')
                                  .toString();
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.history),
                                title: Text('$time  #$vid'),
                                subtitle: Text('临床诊断: $dxCli    中医诊断: $dxTcm'),
                                onTap: (vid == null)
                                    ? null
                                    : () => _openVisitDetail(vid),
                              );
                            },
                          );
                        }(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载患者信息失败：$e')));
    }
  }

  Future<void> _openAddPatientDialog() async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final phone = TextEditingController();
    String? gender = '未知';
    final addr = TextEditingController();
    final allergy = TextEditingController();
    final history = TextEditingController();
    final remark = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('添加新患者'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: '姓名'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入姓名' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phone,
                    decoration: const InputDecoration(labelText: '联系电话'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入联系电话' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(labelText: '性别'),
                    items: const [
                      DropdownMenuItem(value: '男', child: Text('男')),
                      DropdownMenuItem(value: '女', child: Text('女')),
                      DropdownMenuItem(value: '未知', child: Text('未知')),
                    ],
                    onChanged: (v) => gender = v,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: addr,
                    decoration: const InputDecoration(labelText: '住址（可选）'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: allergy,
                    decoration: const InputDecoration(labelText: '过敏史（可选）'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: history,
                    decoration: const InputDecoration(labelText: '既往史（可选）'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: remark,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: '备注（可选）'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            child: const Text('保存'),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                // 注意：字段名与当前项目其它地方保持一致（使用 addr/allergy/history/remark）
                await Db.execute(
                  'INSERT INTO huanzhe (name, phone, gender, addr, allergy, history, remark) '
                  'VALUES (:name,:phone,:gender,:addr,:allergy,:history,:remark) '
                  'ON DUPLICATE KEY UPDATE '
                  ' name=VALUES(name), gender=VALUES(gender), addr=VALUES(addr), '
                  ' allergy=VALUES(allergy), history=VALUES(history), remark=VALUES(remark)',
                  {
                    'name': name.text.trim(),
                    'phone': phone.text.trim(),
                    'gender': gender,
                    'addr': addr.text.trim(),
                    'allergy': allergy.text.trim(),
                    'history': history.text.trim(),
                    'remark': remark.text.trim(),
                  },
                );
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('保存失败：$e')));
              }
            },
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('新患者已保存，请在病历栏姓名框搜索并开始接诊')));
      _load(); // 刷新左侧列表（若需要）
    }
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(k, style: Theme.of(context).textTheme.labelMedium),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(v.isEmpty ? '-' : v)),
        ],
      ),
    );
  }

  Future<void> _openVisitDetail(int visitId) async {
    try {
      final rs = await Db.query(
        'SELECT id, created_at, complaint, present, diag_cli, diag_tcm, remark '
        'FROM jiuzhen WHERE id=:id',
        {'id': visitId},
      );
      if (rs.rows.isEmpty) return;
      final r = rs.rows.first;
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('就诊详情 #$visitId'),
          content: SizedBox(
            width: 640,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv(
                    context,
                    '时间',
                    (r.colByName('created_at') ?? '').toString(),
                  ),
                  _kv(context, '主诉', r.colByName('complaint') ?? ''),
                  _kv(context, '现病史', r.colByName('present') ?? ''),
                  _kv(context, '临床诊断', r.colByName('diag_cli') ?? ''),
                  _kv(context, '中医诊断', r.colByName('diag_tcm') ?? ''),
                  _kv(context, '备注', r.colByName('remark') ?? ''),
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载就诊详情失败：$e')));
    }
  }
}
