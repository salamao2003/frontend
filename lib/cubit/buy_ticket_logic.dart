// buy_ticket_logic.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy_metro/cubit/ticket_data.dart';

class BuyTicketLogic {
  static const String baseUrl = 'https://backend-54v5.onrender.com/api';
  
  // Get stored access token
  static Future<String?> getStoredAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Buy ticket method
  static Future<Map<String, dynamic>> buyTicket(String ticketType, int quantity) async {
    try {
      String? accessToken = await getStoredAccessToken();
      if (accessToken == null) {
        return {
          'success': false,
          'message': 'No access token found'
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tickets/purchase-with-wallet/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'ticket_type': ticketType,
          'quantity': quantity,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to purchase ticket'
        };
      }

    } catch (e) {
      print('Error purchasing ticket: $e');
      return {
        'success': false,
        'message': 'Error occurred while purchasing ticket'
      };
    }
  }
}