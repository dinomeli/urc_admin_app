class Church {
  final int id;
  final String name;
  final String city;
  final String address;

  Church({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
  });

  factory Church.fromJson(Map<String, dynamic> json) {
    return Church(
      id: json['Id'] as int? ?? json['id'] as int? ?? 0, // هم Id هم id رو قبول کن
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      city: json['City'] as String? ?? json['city'] as String? ?? '',
      address: json['Address'] as String? ?? json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'City': city,
      'Address': address,
    };
  }
}