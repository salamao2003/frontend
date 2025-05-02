import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TicketService {
  static const String baseUrl = 'https://backend-54v5.onrender.com/api';

  // Get stored access token
  static Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Get tickets with authorization
  static Future<Map<String, dynamic>> getTickets() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    print('Using token for tickets request: $token');

    if (token == null) {
      return {
        'success': false,
        'message': 'No access token found'
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/tickets/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Tickets API Response Status: ${response.statusCode}');
    print('Tickets API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      // مباشرة إرجاع البيانات كما هي من السيرفر
      return json.decode(response.body);
    }

    return {
      'success': false,
      'message': 'Failed to fetch tickets'
    };
  } catch (e) {
    print('Error fetching tickets: $e');
    return {
      'success': false,
      'message': 'Error fetching tickets: $e'
    };
  }
}
  // Get dashboard data
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final token = await _getAccessToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No access token found'
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tickets/dashboard/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      return {
        'success': false,
        'message': 'Failed to fetch dashboard data'
      };
    } catch (e) {
      print('Error fetching dashboard: $e');
      return {
        'success': false,
        'message': 'Error fetching dashboard data'
      };
    }
  }

  // Buy ticket
  static Future<Map<String, dynamic>> buyTicket(String ticketType, int quantity) async {
    try {
      final token = await _getAccessToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No access token found'
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tickets/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ticket_type': ticketType,
          'quantity': quantity,
        }),
      );

      print('Buy ticket response status: ${response.statusCode}');
      print('Buy ticket response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      }

      return {
        'success': false,
        'message': 'Failed to purchase ticket'
      };
    } catch (e) {
      print('Error purchasing ticket: $e');
      return {
        'success': false,
        'message': 'Error purchasing ticket'
      };
    }
  }

  // Sync tickets
  static Future<Map<String, dynamic>> syncTickets() async {
  try {
    final token = await _getAccessToken();
    
    if (token == null) {
      return {
        'success': false,
        'message': 'No access token found'
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/tickets/sync/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Sync tickets API Response Status: ${response.statusCode}');
    print('Sync tickets API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return {
      'success': false,
      'message': 'Failed to sync tickets. Status: ${response.statusCode}'
    };
  } catch (e) {
    print('Error syncing tickets: $e');
    return {
      'success': false,
      'message': 'Error syncing tickets: $e'
    };
  }
}
static Future<Map<String, dynamic>> getPendingUpgrades() async {

  try {

    final token = await _getAccessToken();

    

    if (token == null) {

      return {

        'success': false,

        'message': 'No access token found'

      };

    }


    final response = await http.get(

      Uri.parse('$baseUrl/tickets/pending-upgrades/'),

      headers: {

        'Authorization': 'Bearer $token',

        'Content-Type': 'application/json',

      },

    );


    if (response.statusCode == 200) {

      return json.decode(response.body);

    }


    return {

      'success': false,

      'message': 'Failed to get pending upgrades'

    };

  } catch (e) {

    print('Error getting pending upgrades: $e');

    return {

      'success': false,

      'message': 'Error getting pending upgrades'

    };

  }

}
  static Future<Map<String, dynamic>> upgradeTicket(String ticketId, String newTicketType) async {
  try {
    final token = await _getAccessToken();
    
    if (token == null) {
      return {
        'success': false,
        'message': 'No access token found'
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/tickets/$ticketId/upgrade-with-wallet/'),
      headers: {
        'Authorization': 'Bearer $token',
        
      },
      body: json.encode({
        'new_ticket_type': newTicketType,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return {
      'success': false,
      'message': 'Failed to upgrade ticket'
    };
  } catch (e) {
    print('Error upgrading ticket: $e');
    return {
      'success': false,
      'message': 'Error upgrading ticket'
    };
  }
}
static Future<Map<String, dynamic>> upgradeTicketWithWallet(String ticketId, String newTicketType) async {
  try {
    final token = await _getAccessToken();
    
    if (token == null) {
      return {
        'success': false,
        'message': 'No access token found'
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/tickets/$ticketId/upgrade-with-wallet/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'new_ticket_type': newTicketType
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return {
      'success': false,
      'message': 'Failed to upgrade ticket'
    };
  } catch (e) {
    print('Error upgrading ticket: $e');
    return {
      'success': false,
      'message': 'Error upgrading ticket'
    };
  }
}
}