class waUser {
  final String? userId;
  final String phoneNumber;

  waUser({this.userId, required this.phoneNumber});

  factory waUser.fromJson(Map<String, dynamic> json) {
    return waUser(
      userId: json['userId']?.toString() ?? '',
      phoneNumber: json['phoneNumber'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber
    };
  }
}
