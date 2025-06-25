import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/article_service.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  final ArticleService _articleService = ArticleService();

  ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            AspectRatio(
              aspectRatio: 16 / 9,
              child:
                  article.imageUrl != null
                      ? Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const Icon(Icons.error, size: 60),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, size: 60),
                      ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Date
                  Text(
                    _formatDate(article.date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    article.descript,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.blue),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              IconButton(
                icon: const Icon(Icons.article),
                onPressed: () {
                  // Already on articles
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_outline),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Article saved')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  // Navigate to profile
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
