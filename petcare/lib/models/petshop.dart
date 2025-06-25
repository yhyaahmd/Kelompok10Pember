class Petshop {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final double rating;
  final double? distance;
  final DateTime createdAt;

  Petshop({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.phone,
    required this.rating,
    this.distance,
    required this.createdAt,
  });

  factory Petshop.fromJson(Map<String, dynamic> json) {
    return Petshop(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      phone: json['phone'],
      rating: double.parse(json['rating'].toString()),
      distance: json['distance'] != null ? double.parse(json['distance'].toString()) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
