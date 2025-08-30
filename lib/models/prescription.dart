class Prescription {
  final int id;
  final int patientId;
  final String type;
  final DateTime createdAt;

  Prescription({
    required this.id,
    required this.patientId,
    required this.type,
    required this.createdAt,
  });

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'],
      patientId: map['patient_id'],
      type: map['type'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
