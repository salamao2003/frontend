import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WalletLogic {
  static const String baseUrl = 'https://backend-54v5.onrender.com/api';

  // جلب بيانات المحفظة
  static Future<Map<String, dynamic>> getWalletDetails() async {
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
        Uri.parse('$baseUrl/wallet/wallet/my_wallet/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Wallet API Response Status: ${response.statusCode}');
      print('Wallet API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return {
            'success': true,
            'data': {
              'id': data['data']['id'],
              'balance': double.parse(data['data']['balance'].toString()),
              'is_active': data['data']['is_active'],
              'created_at': data['data']['created_at'],
              'updated_at': data['data']['updated_at'],
            }
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to fetch wallet details'
      };
    } catch (e) {
      print('Error fetching wallet details: $e');
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  // جلب سجل المعاملات
  static Future<Map<String, dynamic>> getRecentTransactions() async {
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
      Uri.parse('$baseUrl/wallet/transactions/recent/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Recent Transactions Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'data': data['data'],
        'count': data['count'],
      };
    }

    return {
      'success': false,
      'message': 'Failed to fetch recent transactions'
    };
  } catch (e) {
    print('Error fetching recent transactions: $e');
    return {
      'success': false,
      'message': 'Error: $e'
    };
  }
}

  // إضافة رصيد للمحفظة
  static Future<Map<String, dynamic>> addFunds({
  required double amount,
  required String paymentMethodId,
}) async {
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
      Uri.parse('$baseUrl/wallet/wallet/add_funds/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': amount,
        'payment_method_id': paymentMethodId,
      }),
    );

    print('Add Funds Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'data': data,
        'message': data['message'] ?? 'Funds added successfully',
      };
    }

    return {
      'success': false,
      'message': 'Failed to add funds'
    };
  } catch (e) {
    print('Error adding funds: $e');
    return {
      'success': false,
      'message': 'Error: $e'
    };
  }
}
  // إدارة وسائل الدفع
  static Future<Map<String, dynamic>> getPaymentMethods() async {
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
      Uri.parse('$baseUrl/wallet/payment-methods/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Get Payment Methods Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'data': data,
      };
    }

    return {
      'success': false,
      'message': 'Failed to fetch payment methods'
    };
  } catch (e) {
    print('Error fetching payment methods: $e');
    return {
      'success': false,
      'message': 'Error: $e'
    };
  }
}

static Future<Map<String, dynamic>> deletePaymentMethod(String paymentMethodId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      return {
        'success': false,
        'message': 'No access token found'
      };
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/wallet/payment-methods/$paymentMethodId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Delete Payment Method Response: ${response.body}');

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': 'Payment method removed successfully'
      };
    }

    return {
      'success': false,
      'message': 'Failed to delete payment method'
    };
  } catch (e) {
    print('Error deleting payment method: $e');
    return {
      'success': false,
      'message': 'Error: $e'
    };
  }
}

  // إضافة وسيلة دفع جديدة
  static Future<Map<String, dynamic>> addPaymentMethod({
  required String paymentType,
  required String name,
  required String cardLast4,
  required String cardBrand,
  required int cardExpiryMonth,
  required int cardExpiryYear,
  bool isDefault = true,
}) async {
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
      Uri.parse('$baseUrl/wallet/payment-methods/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'payment_type': paymentType,
        'name': name,
        'card_last4': cardLast4,
        'card_brand': cardBrand,
        'card_expiry_month': cardExpiryMonth,
        'card_expiry_year': cardExpiryYear,
        'is_default': isDefault,
      }),
    );

    print('Add Payment Method Response: ${response.body}');

    if (response.statusCode == 201) {
      return {
        'success': true,
        'data': json.decode(response.body),
      };
    }

    return {
      'success': false,
      'message': 'Failed to add payment method',
    };
  } catch (e) {
    print('Error adding payment method: $e');
    return {
      'success': false,
      'message': 'Error: $e',
    };
  }
}

  // التحقق من رصيد كافي للشراء
  static Future<Map<String, dynamic>> checkBalanceForPurchase(double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        return {'success': false, 'message': 'No access token found'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/wallet/check-balance/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      }
      return {'success': false, 'message': 'Failed to check balance'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

}