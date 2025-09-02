import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'menzhen/huanzhe_lan.dart';
import 'menzhen/bingli_lan.dart';
import 'menzhen/lishi_lan.dart';

class MenZhenPage extends StatefulWidget {
  const MenZhenPage({super.key});
  @override
  State<MenZhenPage> createState() => _MenZhenPageState();
}

class _MenZhenPageState extends State<MenZhenPage> {
  DateTimeRange? wanchengJiezhenFanwei;
  Patient? selectedPatient;

  void _openDateRangePicker() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => wanchengJiezhenFanwei = picked);
  }

  void _showPatientsSheet(double height) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: height * 0.9,
        child: HuanzheLan(
          wanchengFanwei: wanchengJiezhenFanwei,
          onTapPickRange: _openDateRangePicker,
          onSelectPatient: (p) {
            setState(() => selectedPatient = p);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showHistorySheet(double height) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: height * 0.9,
        child: LishiLan(
          wanchengFanwei: wanchengJiezhenFanwei,
          onTapPickRange: _openDateRangePicker,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        final isDesktop = w >= 1200;
        final isTablet = w >= 900 && w < 1200;

        if (isDesktop || isTablet) {
          final leftWidth = w * 0.25;
          final rightWidth = w * 0.25;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: leftWidth,
                child: HuanzheLan(
                  wanchengFanwei: wanchengJiezhenFanwei,
                  onTapPickRange: _openDateRangePicker,
                  onSelectPatient: (p) => setState(() => selectedPatient = p),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: BingliLan(
                  key: ValueKey(selectedPatient?.id ?? 'none'),
                  patient: selectedPatient,
                ),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: rightWidth,
                child: LishiLan(
                  wanchengFanwei: wanchengJiezhenFanwei,
                  onTapPickRange: _openDateRangePicker,
                ),
              ),
            ],
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('门诊接诊'),
              actions: [
                IconButton(
                  tooltip: '患者列表',
                  onPressed: () => _showPatientsSheet(h),
                  icon: const Icon(Icons.people_outline),
                ),
                IconButton(
                  tooltip: '历史记录',
                  onPressed: () => _showHistorySheet(h),
                  icon: const Icon(Icons.history),
                ),
              ],
            ),
            body: BingliLan(
              key: ValueKey(selectedPatient?.id ?? 'none'),
              patient: selectedPatient,
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _openDateRangePicker,
              icon: const Icon(Icons.filter_alt_outlined),
              label: const Text('筛选时间段'),
            ),
          );
        }
      },
    );
  }
}
