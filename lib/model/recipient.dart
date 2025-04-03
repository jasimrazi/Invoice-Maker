class Recipient {
  final int? id; // Make id optional
  final String name;
  final String address;
  final String gstin;
  final String place;

  Recipient({
    this.id, // Optional id
    required this.name,
    required this.address,
    required this.gstin,
    required this.place,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include id if provided
      'name': name,
      'address': address,
      'gstin': gstin,
      'place': place,
    };
  }

  factory Recipient.fromMap(Map<String, dynamic> map) {
    return Recipient(
      id: map['id'], // Parse id
      name: map['name'],
      address: map['address'],
      gstin: map['gstin'],
      place: map['place'],
    );
  }

  // Adding the copyWith method
  Recipient copyWith({
    int? id,
    String? name,
    String? address,
    String? gstin,
    String? place,
  }) {
    return Recipient(
      id: id ?? this.id, // Keep current value if null
      name: name ?? this.name,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      place: place ?? this.place,
    );
  }
}
