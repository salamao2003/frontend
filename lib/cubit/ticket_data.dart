import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TicketData {
  static List<Map<String, dynamic>> activeTickets = [];
  static List<Map<String, dynamic>> expiredTickets = [];

  static Future<void> fetchTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://backend-54v5.onrender.com/api/tickets/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final tickets = List<Map<String, dynamic>>.from(data['results']);
          
          activeTickets = tickets.where((ticket) => 
            ticket['status'] == 'ACTIVE'
          ).toList();

          expiredTickets = tickets.where((ticket) => 
            ticket['status'] == 'EXPIRED'
          ).toList();
        }
      }
    } catch (e) {
      print('Error fetching tickets: $e');
    }
  }

  static int getActiveTicketCount(String ticketType) {
    return activeTickets.where((ticket) => 
      ticket['ticket_type'] == ticketType
    ).length;
  }

  static List<Map<String, dynamic>> getActiveTickets(String ticketType) {
    return activeTickets.where((ticket) => 
      ticket['ticket_type'] == ticketType
    ).toList();
  }

  static String? getQRCode(String ticketType, int index) {
    final tickets = getActiveTickets(ticketType);
    if (index < tickets.length) {
      return tickets[index]['qr_code_url'];
    }
    return null;
  }
}