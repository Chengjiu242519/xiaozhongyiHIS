class Patient {
  final int? id;
  final String name;
  final String? phone;
  final String? gender;
  Patient({this.id, required this.name, this.phone, this.gender});

  // 根据你的 Db.query 返回的行对象适配
  static Patient fromRow(row) => Patient(
    id: row.colByName('id') is int
        ? row.colByName('id') as int
        : int.tryParse(row.colByName('id')?.toString() ?? ''),
    name: row.colByName('name') ?? '',
    phone: row.colByName('phone'),
    gender: row.colByName('gender'),
  );
}
