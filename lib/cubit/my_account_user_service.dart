import 'dart:convert';
import 'package:http/http.dart' as http;
import 'my_account_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountUserService {
  static const String baseUrl = 'https://backend-54v5.onrender.com/api';
  final MyAccountAuth _auth = MyAccountAuth();

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      String? token = await _auth.getAccessToken();
      if (token == null) throw Exception('No access token found');

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

 print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        token = await _auth.refreshAccessToken();
        if (token != null) {
          // Retry with new token
          final newResponse = await http.get(
            Uri.parse('$baseUrl/users/profile/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          if (newResponse.statusCode == 200) {
            return json.decode(newResponse.body);
          }
        }
        throw Exception('Authentication failed');
      }
      throw Exception('Failed to load profile');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) throw Exception('No access token found');

      print('Updating profile with data:');
      print('Email: $email');
      
      final response = await http.patch(  // تغيير من put إلى patch
        Uri.parse('https://backend-54v5.onrender.com/api/users/profile/update/'),  // تحديث المسار
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      rethrow;
    }
  }
}