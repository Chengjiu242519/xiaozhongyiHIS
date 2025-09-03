// 患者栏的列表项（就诊中/今日完成）。今日完成会带 visitId 用于读取已完成病历
class MenZhenLieBiaoXiang {
  final int patientId;
  final String name;
  final String phone;
  final DateTime time; // 就诊中：updated_at；今日完成：visit_time
  final bool inSession;
  final int? visitId; // 仅今日完成有值
  MenZhenLieBiaoXiang({
    required this.patientId,
    required this.name,
    required this.phone,
    required this.time,
    required this.inSession,
    this.visitId,
  });
}
