class Patient {
  final int id;
  final String name;
  final String mobile;

  Patient({required this.id, required this.name, required this.mobile});

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(id: map['id'], name: map['name'], mobile: map['mobile']);
  }
}
