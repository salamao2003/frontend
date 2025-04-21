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
  static Future<bool> buyTicket(String ticketType, int quantity) async {
  try {
    String? accessToken = await getStoredAccessToken();
    if (accessToken == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/tickets/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'ticket_type': ticketType,
        'quantity': quantity,
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  } catch (e) {
    print('Error purchasing ticket: $e');
    return false;
  }
}
}