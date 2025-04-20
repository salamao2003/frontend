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
      // Get the stored access token
      String? accessToken = await getStoredAccessToken();
      
      if (accessToken == null) {
        print('No access token found. Please login first.');
        return false;
      }

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

      print('Buy ticket response status: ${response.statusCode}');
      print('Buy ticket response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Store QR code URL
          if (data['data'] is List) {
            for (var ticket in data['data']) {
              String qrCodeUrl = ticket['qr_code_url'] ?? '';
              if (qrCodeUrl.isNotEmpty) {
                TicketData.addQRCode(ticketType, qrCodeUrl);
              }
            }
          } else {
            String qrCodeUrl = data['data']['qr_code_url'] ?? '';
            if (qrCodeUrl.isNotEmpty) {
              TicketData.addQRCode(ticketType, qrCodeUrl);
            }
          }
          return true;
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        print('Token expired or invalid. Please login again.');
        return false;
      }
      return false;
    } catch (e) {
      print('Error purchasing ticket: $e');
      return false;
    }
  }
}