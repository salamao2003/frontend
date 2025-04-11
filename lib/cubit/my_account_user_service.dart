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

      print('Request Token: $token'); // للتحقق من التوكن

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data']; // نرجع data فقط
        } else {
          throw Exception('Failed to load profile: ${responseData['message']}');
        }
      } else if (response.statusCode == 401) {
        token = await _auth.refreshAccessToken();
        if (token != null) {
          final newResponse = await http.get(
            Uri.parse('$baseUrl/users/profile/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          if (newResponse.statusCode == 200) {
            final responseData = json.decode(newResponse.body);
            if (responseData['success'] == true) {
              return responseData['data'];
            }
          }
        }
        throw Exception('Authentication failed');
      }
      throw Exception('Failed to load profile');
    } catch (e) {
      print('Error in getUserProfile: $e');
      throw Exception('Error: $e');
    }
  }

   Future<Map<String, dynamic>> updateProfile({

    String? email,

    String? firstName,

    String? lastName,

    String? phoneNumber,

  }) async {

    try {

      String? token = await _auth.getAccessToken();

      if (token == null) throw Exception('No access token found');


      // إنشاء Map للبيانات المراد تحديثها

      final Map<String, dynamic> updateData = {};

      if (firstName != null) updateData['first_name'] = firstName;

      if (lastName != null) updateData['last_name'] = lastName;

      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;

      if (email != null) updateData['email'] = email;


      print('Updating profile with data: $updateData');

      print('Using token: $token');


      final response = await http.patch(

        Uri.parse('$baseUrl/users/profile/update/'),

        headers: {

          'Authorization': 'Bearer $token',

          'Content-Type': 'application/json',

        },

        body: json.encode(updateData),

      );


      print('Update Response Status: ${response.statusCode}');

      print('Update Response Body: ${response.body}');


      if (response.statusCode == 200) {

        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {

          // حفظ البيانات المحدثة في SharedPreferences

          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('user_profile', json.encode(responseData['data']));

          return responseData['data'];

        } else {

          throw Exception(responseData['message'] ?? 'Failed to update profile');

        }

      } else {

        throw Exception('Failed to update profile: Status ${response.statusCode}');

      }

    } catch (e) {

      print('Error in updateProfile: $e');

      throw Exception('Error updating profile: $e');

    }

  }
Future<Map<String, dynamic>> getStoredProfile() async {

    final prefs = await SharedPreferences.getInstance();

    final storedProfile = prefs.getString('user_profile');

    if (storedProfile != null) {

      return json.decode(storedProfile);

    }

    throw Exception('No stored profile found');

  }

}