// 患者主档：用于在病历栏显示完整基础信息（性别/生日可为空）
class Huanzhe {
  final int id;
  final String name;
  final String phone;
  final String? gender; // 新增：性别
  final DateTime? birthday; // 新增：生日（用于计算年龄）

  Huanzhe({
    required this.id,
    required this.name,
    required this.phone,
    this.gender,
    this.birthday,
  });

  factory Huanzhe.fromRow(Map<String, String?> r) => Huanzhe(
    id: int.parse(r['id']!),
    name: r['name'] ?? '',
    phone: r['phone'] ?? '',
  );
}
