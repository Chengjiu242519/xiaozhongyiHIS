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
