// 患者扩展信息：仅允许在病历栏里修改 3 项（过敏史/既往史/患者备注）
class HuanzheXinXi {
  final int patientId;
  String? guominshi; // 过敏史
  String? jiwangshi; // 既往史
  String? huanzheBeizhu; // 患者备注（patient_remark）
  HuanzheXinXi({
    required this.patientId,
    this.guominshi,
    this.jiwangshi,
    this.huanzheBeizhu,
  });
}
