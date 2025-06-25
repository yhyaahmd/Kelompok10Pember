class Pet {
  final String? id;
  final String nama_hewan;
  final String jenis_hewan;
  final String jenis_perawatan;
  final String tanggal_perawatan;
  final String status_perawtan;

  Pet({
    this.id,
    required this.nama_hewan,
    required this.jenis_hewan,
    required this.jenis_perawatan,
    required this.tanggal_perawatan,
    required this.status_perawtan,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id']?.toString() ?? '',
      nama_hewan: json['nama_hewan'] ?? '',
      jenis_hewan: json['jenis_hewan'] ?? '',
      jenis_perawatan: json['jenis_perawatan'] ?? '',
      tanggal_perawatan: json['tanggal_perawatan'] ?? '',
      status_perawtan: json['status_perawtan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_hewan': nama_hewan,
      'jenis_hewan': jenis_hewan,
      'jenis_perawatan': jenis_perawatan,
      'tanggal_perawatan': tanggal_perawatan,
      'status_perawtan': status_perawtan,
    };
  }
}
