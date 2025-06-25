import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pet.dart';

class PetService {
  static const String baseUrl = 'http://192.168.1.3/modul5Pember/';

  static Future<List<Pet>> fetchPets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get.php'));

      if (response.statusCode == 200) {
        if (response.body == 'null' || response.body.isEmpty) {
          return [];
        }

        print('Response from get.php: ${response.body}');

        final List<dynamic> data = json.decode(response.body);
        final List<Pet> pets = data.map((item) => Pet.fromJson(item)).toList();

        return pets;
      } else {
        print('Error status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load pets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pets: $e');
      return [];
    }
  }

  static Future<bool> addPet(Pet pet) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/post.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nama_hewan': pet.nama_hewan,
          'jenis_hewan': pet.jenis_hewan,
          'jenis_perawatan': pet.jenis_perawatan,
          'tanggal_perawatan': pet.tanggal_perawatan,
          'status_perawtan': pet.status_perawtan,
        },
      );

      print('Raw response from server: ${response.body}');
      print('Status code: ${response.statusCode}');

      try {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['success'] == true;
      } catch (e) {
        print('Error parsing JSON response: $e');
        print('Response was: ${response.body}');
        if (response.body.toLowerCase().contains('berhasil') ||
            response.body.toLowerCase().contains('success')) {
          return true;
        }
        return false;
      }
    } catch (e) {
      print('Error adding pet: $e');
      return false;
    }
  }

  static Future<bool> updatePet(String id, Pet pet) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/put.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': id,
          'nama_hewan': pet.nama_hewan,
          'jenis_hewan': pet.jenis_hewan,
          'jenis_perawatan': pet.jenis_perawatan,
          'tanggal_perawatan': pet.tanggal_perawatan,
          'status_perawtan': pet.status_perawtan,
        },
      );

      print('Raw response from update: ${response.body}');

      try {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['success'] == true;
      } catch (e) {
        print('Error parsing JSON response: $e');
        if (response.body.toLowerCase().contains('berhasil') ||
            response.body.toLowerCase().contains('success')) {
          return true;
        }
        return false;
      }
    } catch (e) {
      print('Error updating pet: $e');
      return false;
    }
  }

  static Future<bool> deletePet(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id': id},
      );

      print('Raw response from delete: ${response.body}');

      try {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['success'] == true;
      } catch (e) {
        print('Error parsing JSON response: $e');
        if (response.body.toLowerCase().contains('berhasil') ||
            response.body.toLowerCase().contains('success')) {
          return true;
        }
        return false;
      }
    } catch (e) {
      print('Error deleting pet: $e');
      return false;
    }
  }
}
