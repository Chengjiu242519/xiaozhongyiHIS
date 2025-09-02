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
                      onTap: () => widget.onSelectPatient(p),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
