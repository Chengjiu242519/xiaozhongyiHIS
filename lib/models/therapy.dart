class Therapy {
  final int id;
  final String name;
  final double price;

  Therapy({required this.id, required this.name, required this.price});

  factory Therapy.fromMap(Map<String, dynamic> map) {
    return Therapy(id: map['id'], name: map['name'], price: map['price']);
  }
}
