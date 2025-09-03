// 门诊草稿（病历栏保存的临时数据）
class MenZhenCaoGao {
  final int patientId;
  String? zhusu;
  String? xianbingshi;
  String? linchuangDx;
  String? zhongyiDx;
  String? beizhu;
  MenZhenCaoGao({
    required this.patientId,
    this.zhusu,
    this.xianbingshi,
    this.linchuangDx,
    this.zhongyiDx,
    this.beizhu,
  });
}
