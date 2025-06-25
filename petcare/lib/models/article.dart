class Article {
  final String id;
  final String title;
  final String descript;
  final String? imageUrl;
  final DateTime date;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.descript,
    this.imageUrl,
    required this.date,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      descript: json['descript'] ?? '',
      imageUrl: json['image_url'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'descript': descript,
      'image_url': imageUrl,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Article copyWith({
    String? id,
    String? title,
    String? descript,
    String? imageUrl,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      descript: descript ?? this.descript,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ArticleResponse {
  final String status;
  final String message;
  final List<Article> articles;

  ArticleResponse({
    required this.status,
    required this.message,
    required this.articles,
  });

  factory ArticleResponse.fromSupabase(List<dynamic> data) {
    return ArticleResponse(
      status: 'success',
      message: 'Articles loaded successfully',
      articles: data.map((json) => Article.fromJson(json)).toList(),
    );
  }
}
