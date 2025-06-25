import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/petuser.dart'; // Sesuaikan path dengan lokasi file petuser.dart

class WaUserService {
  static const String baseUrl = 'http://192.168.1.17/modul5Pember/';

  static Future<List<waUser>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_user.php'));

      if (response.statusCode == 200) {
        if (response.body == 'null' || response.body.isEmpty) {
          return [];
        }

        print('Response from get_user.php: ${response.body}');

        final List<dynamic> data = json.decode(response.body);
        final List<waUser> users =
            data.map((item) => waUser.fromJson(item)).toList();

        return users;
      } else {
        print('Error status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  static Future<bool> addUser(waUser user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/post_user.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nomorTelp': user.nomorTelp ?? '',
          'namaUser': user.namaUser,
          'passwordUser': user.passwordUser,
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
      print('Error adding user: $e');
      return false;
    }
  }

  static Future<bool> updateUser(String id, waUser user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/put_user.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': id,
          'nomorTelp': user.nomorTelp ?? '',
          'namaUser': user.namaUser,
          'passwordUser': user.passwordUser,
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
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> deleteUser(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_user.php'),
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
      print('Error deleting user: $e');
      return false;
    }
  }

  // Method tambahan untuk login
  static Future<waUser?> loginUser(String namaUser, String passwordUser) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'namaUser': namaUser, 'passwordUser': passwordUser},
      );

      print('Login response: ${response.body}');

      if (response.statusCode == 200) {
        try {
          var jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true && jsonResponse['user'] != null) {
            return waUser.fromJson(jsonResponse['user']);
          }
        } catch (e) {
          print('Error parsing login response: $e');
        }
      }
      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }
}
