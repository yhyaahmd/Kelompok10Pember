class waUser {
  final String? nomorTelp;
  final String namaUser;
  final String passwordUser;

  waUser({this.nomorTelp, required this.namaUser, required this.passwordUser});

  factory waUser.fromJson(Map<String, dynamic> json) {
    return waUser(
      nomorTelp: json['nomorTelp']?.toString() ?? '',
      namaUser: json['namaUser'] ?? '',
      passwordUser: json['passwordUser'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomorTelp': nomorTelp,
      'namaUser': namaUser,
      'passwordUser': passwordUser,
    };
  }
}
