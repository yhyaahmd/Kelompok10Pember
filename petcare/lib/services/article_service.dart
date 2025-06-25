import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/article.dart';

class ArticleService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'articles';
  final String _bucketName = 'article-images';

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://fjwnscslvdocpamrwczj.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqd25zY3NsdmRvY3BhbXJ3Y3pqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyNjMyNjEsImV4cCI6MjA2NTgzOTI2MX0.-pxfv3A2g6nMOwWlCW2_40xvk3VwgAl9wvttyotv1BI',
    );
  }

  // Get all articles
  Future<ArticleResponse> getArticles() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return ArticleResponse.fromSupabase(response);
    } catch (e) {
      print('Error fetching articles: $e');
      throw Exception('Failed to load articles: $e');
    }
  }

  // Get article by ID
  Future<Article> getArticleById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Article.fromJson(response);
    } catch (e) {
      print('Error fetching article: $e');
      throw Exception('Failed to load article: $e');
    }
  }

  // Upload image to Supabase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = 'article_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _supabase.storage
          .from(_bucketName)
          .upload(fileName, imageFile);

      final imageUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Create new article
  Future<Article> createArticle({
    required String title,
    required String description,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
      }

      final response = await _supabase
          .from(_tableName)
          .insert({
            'title': title,
            'descript': description,
            'image_url': imageUrl,
            'date': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Article.fromJson(response);
    } catch (e) {
      print('Error creating article: $e');
      throw Exception('Failed to create article: $e');
    }
  }

  // Update article
  Future<Article> updateArticle({
    required String id,
    String? title,
    String? description,
    File? imageFile,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['descript'] = description;
      
      if (imageFile != null) {
        final imageUrl = await uploadImage(imageFile);
        if (imageUrl != null) {
          updateData['image_url'] = imageUrl;
        }
      }

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return Article.fromJson(response);
    } catch (e) {
      print('Error updating article: $e');
      throw Exception('Failed to update article: $e');
    }
  }

  // Delete article
  Future<void> deleteArticle(String id) async {
    try {
      // Get article to delete image from storage
      final article = await getArticleById(id);
      
      // Delete image from storage if exists
      if (article.imageUrl != null) {
        final fileName = article.imageUrl!.split('/').last;
        await _supabase.storage
            .from(_bucketName)
            .remove([fileName]);
      }

      // Delete article from database
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting article: $e');
      throw Exception('Failed to delete article: $e');
    }
  }

  // Get image URL (for backward compatibility)
  String getImageUrl(String imageName) {
    if (imageName.startsWith('http')) {
      return imageName;
    }
    return _supabase.storage
        .from(_bucketName)
        .getPublicUrl(imageName);
  }
}
