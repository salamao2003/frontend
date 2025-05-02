import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MySubscriptionLogic {
  static const String baseUrl = 'https://backend-54v5.onrender.com/api';

  static Future<Map<String, dynamic>> getSubscriptionDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No access token found'
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tickets/subscriptions/active/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Subscription API Response Status: ${response.statusCode}');
      print('Subscription API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': {
            'id': data['id'], // تخزين ال ID
            'subscription_type': data['subscription_type_display'],
            'subscription_type_raw': data['subscription_type'],
            'zones_count': data['zones_count'],
            'price': data['price'],
            'start_date': data['start_date'],
            'end_date': data['end_date'],
            'is_active': data['is_active'],
            'status': data['status'],
            'covered_zones': data['covered_zones'],
            'covered_stations': data['covered_stations'],
            'days_remaining': data['days_remaining'],
          }
        };
      }

      return {
        'success': false,
        'message': 'Failed to fetch subscription details'
      };
    } catch (e) {
      print('Error fetching subscription details: $e');
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }
  // إضافة دالة لإلغاء الاشتراك
  static Future<Map<String, dynamic>> cancelSubscription(int subscriptionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No access token found'
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tickets/subscriptions/$subscriptionId/cancel/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Cancel subscription response: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Subscription cancelled successfully'
        };
      }

      return {
        'success': false,
        'message': 'Failed to cancel subscription'
      };
    } catch (e) {
      print('Error cancelling subscription: $e');
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }
  static Future<Map<String, dynamic>> getQRCode(int subscriptionId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      return {
        'success': false,
        'message': 'No access token found'
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/tickets/subscriptions/$subscriptionId/qr_code/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('QR Code API Response Status: ${response.statusCode}');
    print('QR Code API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'qr_code': data['qr_code']
      };
    }

    return {
      'success': false,
      'message': 'Failed to get QR code'
    };
  } catch (e) {
    print('Error getting QR code: $e');
    return {
      'success': false,
      'message': 'Error: $e'
    };
  }
}
}