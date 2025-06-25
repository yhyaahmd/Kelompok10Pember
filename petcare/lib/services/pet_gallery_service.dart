import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/pet_photo_supabase.dart';
import 'dart:math' as math;

class PetGalleryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // Compress image before upload
  Future<Uint8List> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      // Resize to max 1024x1024 while maintaining aspect ratio
      img.Image resized;
      if (image.width > image.height) {
        resized = img.copyResize(image, width: 1024);
      } else {
        resized = img.copyResize(image, height: 1024);
      }

      // Compress with 85% quality
      return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
    }

    return bytes;
  }

  // Upload pet photo to Supabase
  Future<PetPhotoSupabase?> uploadPetPhoto({
    required File imageFile,
    String? caption,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Check if user is authenticated
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Compress image
      final compressedBytes = await _compressImage(imageFile);

      // Generate unique filename
      final fileName =
          'pet_${DateTime.now().millisecondsSinceEpoch}_${_currentUserId}.jpg';
      final filePath = 'pets/$fileName';

      // Upload to Supabase Storage
      final uploadResponse = await _supabase.storage
          .from('pet-gallery')
          .uploadBinary(filePath, compressedBytes);

      if (uploadResponse.isNotEmpty) {
        // Get public URL
        final imageUrl = _supabase.storage
            .from('pet-gallery')
            .getPublicUrl(filePath);

        // Save metadata to database
        final response =
            await _supabase
                .from('pet_photos')
                .insert({
                  'image_url': imageUrl,
                  'caption': caption,
                  'location': location,
                  'latitude': latitude,
                  'longitude': longitude,
                  'user_id': _currentUserId,
                })
                .select()
                .single();

        return PetPhotoSupabase.fromJson(response);
      }

      return null;
    } catch (e) {
      print('Error uploading pet photo: $e');
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Get all pet photos for current user
  Future<List<PetPhotoSupabase>> getPetPhotos() async {
    try {
      // If no user is authenticated, return empty list
      if (_currentUserId == null) {
        return [];
      }

      final response = await _supabase
          .from('pet_photos')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PetPhotoSupabase.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting pet photos: $e');
      throw Exception('Failed to load photos: $e');
    }
  }

  // Delete pet photo
  Future<void> deletePetPhoto(String photoId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get photo details first
      final photoResponse =
          await _supabase
              .from('pet_photos')
              .select()
              .eq('id', photoId)
              .eq('user_id', _currentUserId!)
              .single();

      if (photoResponse != null) {
        final photo = PetPhotoSupabase.fromJson(photoResponse);

        // Extract file path from URL
        final uri = Uri.parse(photo.imageUrl);
        final pathSegments = uri.pathSegments;
        final filePath = pathSegments
            .sublist(pathSegments.indexOf('pets'))
            .join('/');

        // Delete from storage
        await _supabase.storage.from('pet-gallery').remove([filePath]);

        // Delete from database
        await _supabase
            .from('pet_photos')
            .delete()
            .eq('id', photoId)
            .eq('user_id', _currentUserId!);
      }
    } catch (e) {
      print('Error deleting pet photo: $e');
      throw Exception('Failed to delete photo: $e');
    }
  }

  // Update pet photo caption
  Future<PetPhotoSupabase?> updatePetPhoto({
    required String photoId,
    String? caption,
    String? location,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response =
          await _supabase
              .from('pet_photos')
              .update({'caption': caption, 'location': location})
              .eq('id', photoId)
              .eq('user_id', _currentUserId!)
              .select()
              .single();

      return PetPhotoSupabase.fromJson(response);
    } catch (e) {
      print('Error updating pet photo: $e');
      throw Exception('Failed to update photo: $e');
    }
  }

  // Get pet photos by location (within radius)
  Future<List<PetPhotoSupabase>> getPetPhotosByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      if (_currentUserId == null) {
        return [];
      }

      // This is a simplified version. For production, you might want to use PostGIS
      final response = await _supabase
          .from('pet_photos')
          .select()
          .eq('user_id', _currentUserId!)
          .not('latitude', 'is', null)
          .not('longitude', 'is', null)
          .order('created_at', ascending: false);

      final photos =
          (response as List)
              .map((json) => PetPhotoSupabase.fromJson(json))
              .toList();

      // Filter by distance (simple calculation)
      return photos.where((photo) {
        if (photo.latitude == null || photo.longitude == null) return false;

        final distance = _calculateDistance(
          latitude,
          longitude,
          photo.latitude!,
          photo.longitude!,
        );

        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      print('Error getting pet photos by location: $e');
      throw Exception('Failed to load photos by location: $e');
    }
  }

  // Calculate distance between two points (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
