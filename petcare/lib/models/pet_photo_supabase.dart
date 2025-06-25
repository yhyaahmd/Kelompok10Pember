class PetPhotoSupabase {
  final String id;
  final String imageUrl;
  final String? caption;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final String? userId;

  PetPhotoSupabase({
    required this.id,
    required this.imageUrl,
    this.caption,
    this.location,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.userId,
  });

  factory PetPhotoSupabase.fromJson(Map<String, dynamic> json) {
    return PetPhotoSupabase(
      id: json['id'].toString(),
      imageUrl: json['image_url'] ?? '',
      caption: json['caption'],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'caption': caption,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }
}
