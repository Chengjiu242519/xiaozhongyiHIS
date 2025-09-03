import 'package:flutter/material.dart';
import '../../shuju_moban/menzhen_liebiao_xiang.dart';

class HuanzheLan extends StatefulWidget {
  final List<MenZhenLieBiaoXiang> jiuzhenzhong;
  final List<MenZhenLieBiaoXiang> jinriwancheng;
  final Future<void> Function() onShuaxin;
  final Future<void> Function(String guanjianzi) onSousuoJieZhen;
  // 新建患者回调：姓名、性别、年龄、电话
  final Future<void> Function(
    String xingming,
    String xingbie,
    int nianling,
    String dianhua,
  )
  onXinjianHuanzhe;
  final void Function(MenZhenLieBiaoXiang) onDianJiLieBiao;

  const HuanzheLan({
    super.key,
    required this.jiuzhenzhong,
    required this.jinriwancheng,
    required this.onShuaxin,
    required this.onSousuoJieZhen,
    required this.onXinjianHuanzhe,
    required this.onDianJiLieBiao,
  });

  @override
  State<HuanzheLan> createState() => _HuanzheLanState();
}

class _HuanzheLanState extends State<HuanzheLan> {
  final _sousuo = TextEditingController();
  final _xinName = TextEditingController();
  final _xinPhone = TextEditingController();
  final _xinNianling = TextEditingController();
  String? _xinXingbie; // 男/女/未知

  bool get _keyong =>
      _xinName.text.trim().isNotEmpty &&
      _xinPhone.text.trim().isNotEmpty &&
      _xinXingbie != null &&
      int.tryParse(_xinNianling.text.trim()) != null &&
      (int.tryParse(_xinNianling.text.trim()) ?? 0) > 0;

  Future<void> _tanChuangXinHuanzhe() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('新建患者（必填）'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _xinName,
                decoration: const InputDecoration(labelText: '姓名 *'),
                onChanged: (_) => setS(() {}),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _xinXingbie,
                items: const [
                  DropdownMenuItem(value: '男', child: Text('男')),
                  DropdownMenuItem(value: '女', child: Text('女')),
                  DropdownMenuItem(value: '未知', child: Text('未知')),
                ],
                onChanged: (v) => setS(() => _xinXingbie = v),
                decoration: const InputDecoration(labelText: '性别 *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _xinNianling,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '年龄（岁） *'),
                onChanged: (_) => setS(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _xinPhone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: '手机号 *'),
                onChanged: (_) => setS(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: _keyong ? () => Navigator.pop(ctx, true) : null,
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && _keyong) {
      final nl = int.parse(_xinNianling.text.trim());
      await widget.onXinjianHuanzhe(
        _xinName.text.trim(),
        _xinXingbie!,
        nl,
        _xinPhone.text.trim(),
      );
      _sousuo.text = _xinName.text.trim(); // 便于接诊
      _xinName.clear();
      _xinPhone.clear();
      _xinNianling.clear();
      _xinXingbie = null;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _sousuo,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: '按姓名/电话搜索接诊',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => widget.onSousuoJieZhen(_sousuo.text.trim()),
                child: const Text('接诊'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: _tanChuangXinHuanzhe,
                icon: const Icon(Icons.person_add),
                label: const Text('新患者'),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onShuaxin,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            children: [
              const ListTile(title: Text('就诊中'), dense: true),
              ...widget.jiuzhenzhong.map(
                (e) => ListTile(
                  leading: const Icon(Icons.play_circle_fill),
                  title: Text(e.name),
                  subtitle: Text('${e.phone}  · ${e.time}'),
                  onTap: () => widget.onDianJiLieBiao(e),
                ),
              ),
              const Divider(),
              const ListTile(title: Text('今日完成'), dense: true),
              ...widget.jinriwancheng.map(
                (e) => ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: Text(e.name),
                  subtitle: Text('${e.phone}  · ${e.time}'),
                  onTap: () => widget.onDianJiLieBiao(e),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
