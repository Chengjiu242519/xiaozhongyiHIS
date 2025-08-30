class Visit {
  final int id;
  final String chiefComplaint;
  final String diagnosis;
  final String doctor;
  final DateTime visitTime;

  Visit({
    required this.id,
    required this.chiefComplaint,
    required this.diagnosis,
    required this.doctor,
    required this.visitTime,
  });

  factory Visit.fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id'],
      chiefComplaint: map['chief_complaint'],
      diagnosis: map['diagnosis'],
      doctor: map['doctor'],
      visitTime: DateTime.parse(map['visit_time']),
    );
  }
}
